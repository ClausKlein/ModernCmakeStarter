#include <greeter/greeter.h>
// XXX #include <greeter/version.h>

#include <cxxopts.hpp>
#include <iostream>
#include <string>
#include <unordered_map>

// TODO(CK): [bugprone-exception-escape]
auto main(int argc, char** argv) -> int {
    const std::unordered_map<std::string, greeter::LanguageCode> languages{
        {"en", greeter::LanguageCode::EN},
        {"de", greeter::LanguageCode::DE},
        {"es", greeter::LanguageCode::ES},
        {"fr", greeter::LanguageCode::FR},
    };

    cxxopts::Options options(*argv, "A program to welcome the world!");

    std::string language;
    std::string name;

    // clang-format off
    options.add_options()
      ("h,help", "Show help")
      // ("v,version", "Print the current version number")
      ("n,name", "Name to greet", cxxopts::value(name)->default_value("World"))
      ("l,lang", "Language code to use", cxxopts::value(language)->default_value("en"))
    ;
    // clang-format on

    auto result = options.parse(argc, argv);

    if (result["help"].as<bool>()) {
        std::cout << options.help() << '\n';
        return 0;
    }

    // if (result["version"].as<bool>()) {
    //   std::cout << "Greeter, version " << GREETER_VERSION << '\n';
    //   return 0;
    // }

    auto langIt = languages.find(language);
    if (langIt == languages.end()) {
        std::cerr << "unknown language code: " << language << '\n';
        return 0;
    }

    const greeter::Greeter greeter(name);
    std::cout << greeter.greet(langIt->second) << '\n';

    return 0;
}
