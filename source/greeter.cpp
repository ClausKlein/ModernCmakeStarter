#include "greeter/greeter.h"

#include <fmt/format.h>

using greeter::Greeter;

Greeter::Greeter(std::string _name) : name(std::move(_name)) {}

[[nodiscard]] std::string Greeter::greet(LanguageCode lang) const {
    switch (lang) {
        default:
        case LanguageCode::EN:
            return fmt::format("Hello, {}!", name);
        case LanguageCode::DE:
            return fmt::format("Hallo {}!", name);
        case LanguageCode::ES:
            return fmt::format("¡Hola {}!", name);
        case LanguageCode::FR:
            return fmt::format("Bonjour {}!", name);
    }
}
