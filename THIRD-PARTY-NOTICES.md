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

## NVIDIA runtime in the RTX 20/30 bundle

The RTX 20/30 V8 bundle includes a third-party modified NVIDIA neural runtime, installed as `runtimes/compatible/nvngx_dlssnr.dll`. Its supplied filename is `nvngx_dlssnr_309_plain_xnp255_fp16all_rtx2030_V8.dll` and its SHA-256 is `b5046907fb80e90926c6aa275b48dc7ffb81cfa05d46380ddc66c72692d777ba`. It is a different file from V8b and is not an unmodified NVIDIA driver binary. RTX 20 compatibility and this V8 bundle have not been hardware-tested.

NVIDIA's runtime is proprietary and the community-modified runtime is not covered by this project's MIT license. The [NVIDIA RTX SDKs License](licenses/NVIDIA-DLSS-SDK-LICENSE.txt) is included for reference; the applicable rights for the modified runtime are separate. The original upstream project also [identifies its Ada-patched NVIDIA runtime as a third-party modified build](https://github.com/xilla420/dlss5-wow-sidecar/blob/main/THIRD-PARTY-NOTICES.md). The V8 bundle does not include `nvngx_dlss.dll`. RTX 40/50 users provide their own compatible neural runtime. The original runtime-free package remains available.
