# Third-party components

Dlss5ForWOW is a fork of [xilla420/dlss5-wow-sidecar](https://github.com/xilla420/dlss5-wow-sidecar). The project source retains the upstream MIT license and copyright notice in [LICENSE](LICENSE). Components below are separate works governed by their own licenses.

## Public release

| Component | Publisher and purpose | License / source |
| --- | --- | --- |
| `dxgi.dll` | crosire, ReShade 6.8.0 add-on-enabled build; loaded by the sidecar process | [BSD 3-Clause](licenses/ReShade-LICENSE.md), [source](https://github.com/crosire/reshade/tree/v6.8.0) |
| `renodx-dlss5.addon64` | RenoDX DLSS 5 Generic add-on | [MIT](licenses/RenoDX-LICENSE.txt), [source](https://github.com/clshortfuse/renodx) |
| Dear ImGui | Compiled into the manager | [MIT](licenses/Dear-ImGui-LICENSE.txt) |
| toml++ | Compiled into the application | [MIT](licenses/tomlplusplus-LICENSE.txt) |
| NVIDIA DLSS SDK | NGX SDK used when compiling the application | [NVIDIA RTX SDKs License](licenses/NVIDIA-DLSS-SDK-LICENSE.txt), [source](https://github.com/NVIDIA/DLSS) |
| NVIDIA Optical Flow D3D12 headers | NVIDIA header definitions used at build time | [Header license](licenses/NVIDIA-Optical-Flow-Header-LICENSE.txt) |

The ReShade and RenoDX binaries in the public package are taken from the original upstream 0.6.0 distribution. Their SHA-256 digests are listed in the build manifest. See `assets/fonts/` for SIL Open Font License notices for fonts embedded in the manager, and [art provenance](assets/art/PROVENANCE.md) for its artwork.

## User-supplied NVIDIA runtimes

The public release does **not** include `nvngx_dlssnr.dll` or `nvngx_dlss.dll`. The user supplies them separately. NVIDIA's runtime is proprietary, and community-modified variants are not covered by the project's MIT license. In particular, the RTX 20/30 V8b variant and the RTX 40 Ada-patched build are third-party modifications. Consult the terms applicable to the files you obtain. RTX 20 compatibility has not been verified on hardware.
