#include <iostream>
#include <iomanip>
#include <chrono>
#include <unordered_map>
#include <vector>
#include <map>
#include <fstream>
#include <unistd.h>
#include <cassert>
#include <gflags/gflags.h>
#include <cstring>
#include <array>
#include <sched.h>
#include <algorithm>
#include <random>
#include <atomic>
#include <sstream>
#include <malloc.h>
#include <mutex>
#include <thread>

#include <bsoncxx/builder/basic/document.hpp>
#include <bsoncxx/json.hpp>
#include <mongocxx/client.hpp>
#include <mongocxx/instance.hpp>
#include <mongocxx/stdx.hpp>
#include <mongocxx/uri.hpp>

#include "../util/affinity.hpp"

using bsoncxx::builder::basic::kvp;
using bsoncxx::builder::basic::make_array;
using bsoncxx::builder::basic::make_document;

DEFINE_uint64(str_key_size, 8, "size of key (bytes)");
DEFINE_uint64(str_value_size, 100, "size of value (bytes)");
DEFINE_uint64(num_threads, 1, "the number of threads");
DEFINE_uint64(time_interval, 10, "the time interval of insert operations");

DEFINE_bool(first_mode, true, "fist mode start multiply clients on the same mongoDB server");

DEFINE_string(URI, "mongodb://localhost:27017", "the uri of mongoDB");
DEFINE_string(client_name, "mydb_", "the name of client");
DEFINE_string(collection_name, "test_", "the name of collection");
DEFINE_string(report_prefix, "[report] ", "prefix of report data");
DEFINE_string(core_binding, "", "Core Binding, example : 0,1,16,17");
DEFINE_string(URI_set, "", "URIs of different connections ,example : mongodb://localhost:27017, mongodb://localhost:27018");

void standard_report(const std::string &prefix, const std::string &name, const std::string &value)
{
    std::cout << FLAGS_report_prefix << prefix + "_" << name << " : " << value << std::endl;
}

class mongodbBenchmark
{
private:
    /* data */
public:
    uint64_t key_size;
    uint64_t value_size;
    uint64_t num_of_ops;
    uint64_t num_threads;
    uint64_t time_interval;

    std::vector<std::string> URIs;
    std::mutex cout_mutex;

    std::string client_name;
    std::string collection_name;
    std::string load_benchmark_prefix = "load";
    std::string core_binding;

    barrier_t barrier;

    bool first_mode;

    std::atomic<bool> stop_flag;

    std::string common_value;

    // uint64_t duration_ns;

    mongodbBenchmark(int argc, char **argv);
    ~mongodbBenchmark();
    std::string from_uint64_to_string(uint64_t value,uint64_t value_size);
    void split_string_from_input(std::vector<int> & splited_str, std::string input_str);

    void clientThread(int thread_id, uint64_t core_id);
    void load_and_run();

    void benchmark_report(const std::string benchmark_prefix, const std::string &name, const std::string &value)
    {
        standard_report(benchmark_prefix, name, value);
    }

    void sync_barrier(){
        barrier_cross(&this->barrier);
    }
};

mongodbBenchmark::mongodbBenchmark(int argc, char **argv):stop_flag(false)
{
    google::ParseCommandLineFlags(&argc, &argv, false);

    this->client_name = FLAGS_client_name;
    this->collection_name = FLAGS_client_name;

    this->num_threads = FLAGS_num_threads;
    this->core_binding = FLAGS_core_binding;
    this->first_mode = FLAGS_first_mode;

    this->key_size = FLAGS_str_key_size;
    this->value_size = FLAGS_str_value_size;
    this->time_interval = FLAGS_time_interval;

    barrier_init(&this->barrier,this->num_threads);
    
    if (FLAGS_URI_set.size() != 0)
    {
        std::stringstream ss(FLAGS_URI_set);
        std::string item;
        while (std::getline(ss, item, ','))
        {
            URIs.push_back(item);
            // std::cout<<item<<" ";
        }
    }

    for (int i = 0; i < value_size; i++)
    {
        common_value += (char)('a' + (i % 26));
    }

}

mongodbBenchmark::~mongodbBenchmark()
{
}

std::string mongodbBenchmark::from_uint64_to_string(uint64_t value,uint64_t value_size)
{
    std::stringstream ss;
    ss << std::setfill('0') << std::setw(value_size) << std::hex << value;
    std::string str = ss.str();
    if (str.length() > value_size) {
        str = str.substr(str.length() - value_size);
    }
    return ss.str();
}

void mongodbBenchmark::split_string_from_input(std::vector<int>& splited_str, std::string input_str)
{
    if (input_str.size() != 0)
    {
        std::stringstream ss(input_str);
        std::string item;
        while (std::getline(ss, item, ','))
        {
            splited_str.push_back(std::stoi(item));
            // std::cout<<std::stoi(item)<<" ";
        }
    }
}

void mongodbBenchmark::load_and_run()
{
    mongocxx::instance instance{}; // This should be done only once.

    // Create and start client threads
    std::vector<std::thread> threads;
    std::vector<int> core_ids;
    split_string_from_input(core_ids, core_binding);


    for (int i = 0; i < num_threads; i++)
    {
        uint64_t core_id = core_ids[i];
        // std::cout<<core_id<<std::endl;
        threads.emplace_back([this, i, core_id]()
                             { this->clientThread(i, core_id); });
    }

    std::this_thread::sleep_for(std::chrono::seconds(time_interval));
    stop_flag.store(true);

    // Wait for all client threads to finish
    auto start_time = std::chrono::high_resolution_clock::now();
    for (auto &thread : threads)
    {
        thread.join();
    }


    double duration_s = double(time_interval);
    double duration_ns = duration_s * (1000.0 * 1000 * 1000);
    double throughput = num_of_ops / duration_s;
    double average_latency_ns = (double)duration_ns / num_of_ops;

    benchmark_report(load_benchmark_prefix, "overall_duration_ns", std::to_string(duration_ns));
    benchmark_report(load_benchmark_prefix, "overall_duration_s", std::to_string(duration_s));
    benchmark_report(load_benchmark_prefix, "overall_throughput", std::to_string(throughput));
    benchmark_report(load_benchmark_prefix, "overall_average_latency_ns", std::to_string(average_latency_ns));
}

void mongodbBenchmark::clientThread(int thread_id, uint64_t core_id)
{
    set_affinity(core_id);

    std::lock_guard<std::mutex> lock(cout_mutex);
    mongocxx::uri uri;
    if (first_mode)
    {
        uri=mongocxx::uri(FLAGS_URI);
    }
    else
    {
        uri=mongocxx::uri(URIs[thread_id]);
    }
    // std::cout << "URI: " << uri.to_string() << std::endl;
    mongocxx::client client(uri);
    client_name+=std::to_string(thread_id);
    collection_name+=std::to_string(thread_id);
    auto db = client[client_name];
    auto collection = db[collection_name];

    mongocxx::write_concern wc;
    wc.nodes(0);       
    wc.journal(false); 

    collection.write_concern(wc);

    uint64_t rand=0;
    std::string key;
    while (!stop_flag.load()) {
        key=from_uint64_to_string(rand,key_size);
        auto insert_one_result = collection.insert_one(make_document(kvp(key, common_value)));
        rand++;
    }
    num_of_ops+=rand;
    collection.drop();
}
