# Dlss5ForWOW

[中文](#中文) · [English](#english) · [Releases](https://github.com/AreChen/Dlss5ForWOW/releases) · [上游 / Upstream](https://github.com/xilla420/dlss5-wow-sidecar)

## 中文

Dlss5ForWOW 是基于 [xilla420 的 DLSS 5 WoW Sidecar](https://github.com/xilla420/dlss5-wow-sidecar) 0.6.0 的独立分支。它在独立进程中捕获游戏画面、执行神经渲染并以叠加层显示；不向 Wow.exe 注入代码。它不是帧生成工具，也不能获得游戏原生的深度和运动矢量。请将程序放在游戏目录之外。第三方工具无法保证符合游戏规则或保证账号安全。

### 显卡和运行库

| 显卡 | 运行库选择 | 状态 |
| --- | --- | --- |
| RTX 20 / Turing | 随包 V8，或自行准备 V8b | 实验性；RTX 20 **未经实机验证** |
| RTX 30 / Ampere | 随包 V8，或自行准备 V8b | 实验性；V8 未实测，V8b 曾在 RTX 3080 Ti 的捕获场景中运行 |
| RTX 40 / Ada | 310.8.0 Ada 补丁版 | 沿用上游支持 |
| RTX 50 / Blackwell | 310.9.16 官方版或 310.8.0 Ada 补丁版 | 沿用上游支持 |

完整包使用 310.9.16 **V8** 社区修改版，SHA-256 为 `b5046907fb80e90926c6aa275b48dc7ffb81cfa05d46380ddc66c72692d777ba`。它与此前在 RTX 3080 Ti 上使用的 V8b 是不同文件；此 V8 包和 RTX 20 兼容性尚未经实机验证。

### 安装

1. RTX 20/30 用户下载 `Dlss5ForWOW-v1.0.0-RTX20-30-with-V8.zip`，解压到《魔兽世界》文件夹之外。包内已放入指定的 V8 运行库、ReShade 和 RenoDX。
2. 运行 `wowsidecar-manager.exe`。1.0.0 程序不认识此 V8 文件的哈希，检查页面可能显示未知版本警告；程序仍会尝试加载它。
3. 启动游戏并设置为**无边框窗口**，在管理器选择客户端，点击 **Start overlay / 启动叠加层**。默认启动快捷键是 `Ctrl+Alt+S`。
4. RTX 40/50 用户自行准备适合显卡的 `nvngx_dlssnr.dll`，在 **Setup / 安装** 页面安装。原 `Dlss5ForWOW-v1.0.0-win-x64.zip` 是不含 NVIDIA 运行库的精简包。`nvngx_dlss.dll` 未包含；需要 DLSS 超分辨率路径时自行提供。

神经处理目前按捕获画面的实际分辨率运行，并不会自动降到建议分辨率；高分辨率会占用更多 GPU 时间。检查页面和日志可用于确认运行库是否加载及诊断错误。详见 [第三方声明](THIRD-PARTY-NOTICES.md)。

## English

Dlss5ForWOW is a fork of [xilla420's DLSS 5 WoW Sidecar](https://github.com/xilla420/dlss5-wow-sidecar) 0.6.0. It captures the game and applies neural rendering in a separate process, presenting the result as an overlay; it does not inject code into Wow.exe. It is not frame generation and does not have access to native game depth or motion vectors. Keep the application outside the WoW directory. No third-party tool can guarantee compliance with game rules or account safety.

RTX 20 support is experimental and **untested on hardware**. RTX 30 support is experimental; the 310.9.16 V8b runtime was previously observed on an RTX 3080 Ti. The V8b SHA-256 is `e92cb312684e4c5f34d34dbbc7510aa83f57218c4ac101fe1b4d505e5d268f59`. RTX 40 uses the Ada-patched 310.8.0 runtime; RTX 50 can use stock 310.9.16 or the Ada-patched runtime.

For RTX 20/30, download `Dlss5ForWOW-v1.0.0-RTX20-30-with-V8.zip` and extract it outside the game folder. It includes the V8 neural runtime, ReShade and RenoDX. The original v1.0.0 executable does not recognize the V8 hash and may show an unknown-build warning; it will still attempt to load the runtime. This V8 bundle has not been hardware-tested. RTX 40/50 users must provide an appropriate runtime themselves. The original `Dlss5ForWOW-v1.0.0-win-x64.zip` remains available as a runtime-free package. `nvngx_dlss.dll` is not included and is optional for the experimental upscaling path. Start WoW in borderless windowed mode and select **Start overlay**, or press `Ctrl+Alt+S`. The neural pass runs at capture resolution: the advisory matrix does not automatically downscale it.

### Build

Windows 11 x64, Visual Studio 2022 with C++20, Windows SDK with `dxc`, CMake 3.28+, the NVIDIA DLSS SDK and the NVIDIA Optical Flow SDK D3D12 headers are required. Configure with `-DSIDECAR_REQUIRE_SDKS=ON -DDLSS_SDK_DIR=<path> -DNVOF_SDK_DIR=<path>`, then build the `wowsidecar` and `wowsidecar-manager` targets in Release mode. CMake fetches Dear ImGui, toml++ and Catch2 unless their FetchContent source paths are supplied locally. Use `tools/package_release.ps1` to create the runtime-free base, then `tools/package_v8_bundle.ps1` to assemble the RTX 20/30 V8 package. Source is MIT licensed; third-party components retain their own terms: [notices](THIRD-PARTY-NOTICES.md), [licenses](licenses/).
