#include "neural/RuntimeManifest.h"

#include "core/I18n.h"

#include <algorithm>
#include <array>
#include <cctype>

namespace sidecar {
namespace {

struct ManifestRow {
  const char* sha256;
  const char* version;
  RuntimeVariant variant;
};

// Digests are stored lowercase; LookupRuntime normalises before comparing.
//
// These builds have been observed on hardware, but not on every architecture
// for which they are offered. The 310.8.0 entry was
// confirmed twice over during the M3 Task 4 spike: renodx-dlss5.addon64 reported
// it as a reference match, and the file carries a valid NVIDIA Authenticode
// signature.
constexpr std::array<ManifestRow, 4> kManifest{{
    {"e16bcf15e16e13f527491cdf7845b2fe6521a738d8f7c9c721866a8496e1fc8e",
     "310.8.0", RuntimeVariant::Stock},
    // Valid NVIDIA Authenticode signature, 266 MB, "DVS PRODUCTION". Verified on
    // an RTX PRO 6000 Blackwell against testpattern at 1280x720: feature 18
    // creates and evaluates, and the GPU wait drops from 2.85 to 1.7 ms against
    // the Ada-patched 310.8.0 on the same card. No Ada build exists yet, so on
    // RTX 40 this is still the stock-on-Ada 0xbad00001 case.
    {"2bc19bc09a7b89dd44f73e2ac0108fcc586e2154bdd0830f242f4f040e28789f",
     "310.9.16", RuntimeVariant::Stock},
    // Same version and byte count as the stock build, and it still carries
    // NVIDIA's signature block -- but Authenticode reports HashMismatch,
    // because the Blackwell-built CUDA binaries inside were replaced with
    // Ada-compatible ones. Verified on an RTX 4080: with the stock build,
    // neural-rendering feature creation fails with a bare 0xbad00001; with this
    // one it creates and evaluates. That is the whole reason this row exists.
    {"e67dee209320cdafe0e93e45675d7aa34323a53acc57a72b2e40a181581c989a",
     "310.8.0", RuntimeVariant::AdaPatched},
    // Feature 18 created and evaluated on an RTX 3080 Ti. Its RTX 20 support
    // remains experimental and has not been validated on Turing hardware.
    {"e92cb312684e4c5f34d34dbbc7510aa83f57218c4ac101fe1b4d505e5d268f59",
     "310.9.16 V8b", RuntimeVariant::Rtx2030V8b},
}};

std::string ToLower(std::string_view text) {
  std::string out(text);
  std::transform(out.begin(), out.end(), out.begin(), [](unsigned char c) {
    return static_cast<char>(std::tolower(c));
  });
  return out;
}

constexpr size_t kDigestChars = 64;

}  // namespace

std::optional<RuntimeEntry> LookupRuntime(std::string_view sha256Hex) {
  // Reject anything that is not digest-shaped before comparing. Without this a
  // truncated digest could prefix-match nothing and still cost a scan, and worse,
  // an empty string would read as a legitimate "no digest" lookup.
  if (sha256Hex.size() != kDigestChars) return std::nullopt;

  const std::string needle = ToLower(sha256Hex);
  for (const auto& row : kManifest) {
    if (needle == row.sha256) {
      return RuntimeEntry{row.version, row.variant};
    }
  }
  return std::nullopt;
}

std::string DescribeRuntime(std::string_view filePath, std::string_view sha256Hex) {
  const auto entry = LookupRuntime(sha256Hex);
  if (entry) {
    return std::string(filePath) + Tr(" is the ") + ToString(entry->variant) +
           Tr(" runtime, version ") + entry->version + ".";
  }
  if (sha256Hex.empty()) {
    return std::string(filePath) + Tr(" could not be read, so it has no digest.");
  }
  return std::string(filePath) +
         Tr(" is not a build this manifest knows. Its SHA-256 is ") +
         std::string(sha256Hex) + Tr(" -- quote that when reporting it.");
}

RuntimeVariant VariantForArchitecture(GpuArch arch) {
  switch (arch) {
    case GpuArch::Blackwell: return RuntimeVariant::Stock;
    case GpuArch::Ada:       return RuntimeVariant::AdaPatched;
    case GpuArch::Ampere:    return RuntimeVariant::Rtx2030V8b; // Experimental.
    case GpuArch::Turing:    return RuntimeVariant::Rtx2030V8b; // Unverified.
    default:                 return RuntimeVariant::None;
  }
}

RuntimeCompatibility CheckRuntimeCompatibility(GpuArch arch, RuntimeVariant variant) {
  if (arch != GpuArch::Turing && arch != GpuArch::Ampere &&
      arch != GpuArch::Ada && arch != GpuArch::Blackwell) {
    return RuntimeCompatibility::UnsupportedArchitecture;
  }
  switch (variant) {
    // The older Ada patch was observed on Ampere, Ada and Blackwell; no
    // evidence establishes that it can run on Turing.
    case RuntimeVariant::AdaPatched:
      return arch == GpuArch::Turing ? RuntimeCompatibility::WrongVariant
                                    : RuntimeCompatibility::Ok;
    case RuntimeVariant::Rtx2030V8b:
      return (arch == GpuArch::Turing || arch == GpuArch::Ampere)
                 ? RuntimeCompatibility::Ok : RuntimeCompatibility::WrongVariant;
    case RuntimeVariant::Stock:
      return arch == GpuArch::Blackwell ? RuntimeCompatibility::Ok
                                        : RuntimeCompatibility::WrongVariant;
    default:
      return RuntimeCompatibility::WrongVariant;
  }
}

std::string DescribeCompatibility(GpuArch arch, RuntimeVariant variant) {
  switch (CheckRuntimeCompatibility(arch, variant)) {
    case RuntimeCompatibility::Ok:
      return {};
    case RuntimeCompatibility::UnsupportedArchitecture:
      return std::string(Tr("This GPU (")) + ToString(arch) +
             Tr(") is outside the supported matrix; neural rendering needs RTX 20, 30, 40 or 50.");
    case RuntimeCompatibility::WrongVariant:
    default:
      if (arch == GpuArch::Ada && variant == RuntimeVariant::Stock) {
        // The specific case worth spelling out, because the symptom is a bare
        // failure code at feature creation and nothing else says why.
        return Tr("This is the stock runtime, which is built for Blackwell. On an "
                  "Ada card neural-rendering feature creation fails with no "
                  "explanation. An Ada-compatible build of nvngx_dlssnr.dll is "
                  "required.");
      }
      return std::string(Tr("The ")) + ToString(variant) +
             Tr(" runtime does not run on ") + ToString(arch) + ".";
  }
}

const char* ToString(RuntimeVariant variant) {
  switch (variant) {
    case RuntimeVariant::Stock:      return "stock NVIDIA";
    case RuntimeVariant::AdaPatched: return "Ada-patched";
    case RuntimeVariant::Rtx2030V8b: return "RTX 20/30 V8b";
    default:                         return "none";
  }
}

}  // namespace sidecar
