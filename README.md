# Dlss5ForWOW

[中文](#中文) · [English](#english) · [Releases](https://github.com/AreChen/Dlss5ForWOW/releases) · [上游 / Upstream](https://github.com/xilla420/dlss5-wow-sidecar)

## 中文

Dlss5ForWOW 是基于 [xilla420 的 DLSS 5 WoW Sidecar](https://github.com/xilla420/dlss5-wow-sidecar) 0.6.0 的独立分支。它在独立进程中捕获游戏画面、执行神经渲染并以叠加层显示；不向 Wow.exe 注入代码。它不是帧生成工具，也不能获得游戏原生的深度和运动矢量。请将程序放在游戏目录之外。第三方工具无法保证符合游戏规则或保证账号安全。

### 显卡和运行库

| 显卡 | 运行库选择 | 状态 |
| --- | --- | --- |
| RTX 20 / Turing | 310.9.16 V8b，RTX 20/30 社区修改版 | 实验性；RTX 20 **未经实机验证** |
| RTX 30 / Ampere | 310.9.16 V8b，RTX 20/30 社区修改版 | 实验性；曾在 RTX 3080 Ti 的捕获场景中运行 |
| RTX 40 / Ada | 310.8.0 Ada 补丁版 | 沿用上游支持 |
| RTX 50 / Blackwell | 310.9.16 官方版或 310.8.0 Ada 补丁版 | 沿用上游支持 |

V8b 的 SHA-256：`e92cb312684e4c5f34d34dbbc7510aa83f57218c4ac101fe1b4d505e5d268f59`。不同版本可能有相同的文件版本号，请以哈希确认。RTX 20/30 的兼容性和速度取决于具体显卡、驱动及模型，RTX 20 并未验证。

### 安装

1. 下载 `Dlss5ForWOW-v1.0.0-win-x64.zip`，解压到《魔兽世界》文件夹之外。
2. 公开发行包包含程序、ReShade 和 RenoDX，**不包含 NVIDIA 运行库**。自行准备适合显卡的 `nvngx_dlssnr.dll`。如需 DLSS 超分辨率功能，还需另备 `nvngx_dlss.dll`。请遵循各文件的使用条款。
3. 运行 `wowsidecar-manager.exe`，在 **Setup / 安装** 页面选择神经渲染运行库文件并安装。程序会按照识别出的版本放到正确的运行库目录。也可按界面提示安装 `nvngx_dlss.dll`。
4. 启动游戏并设置为**无边框窗口**，在管理器选择客户端，点击 **Start overlay / 启动叠加层**。默认启动快捷键是 `Ctrl+Alt+S`。

神经处理目前按捕获画面的实际分辨率运行，并不会自动降到建议分辨率；高分辨率会占用更多 GPU 时间。检查页面和日志可用于确认运行库是否加载及诊断错误。详见 [第三方声明](THIRD-PARTY-NOTICES.md)。

## English

Dlss5ForWOW is a fork of [xilla420's DLSS 5 WoW Sidecar](https://github.com/xilla420/dlss5-wow-sidecar) 0.6.0. It captures the game and applies neural rendering in a separate process, presenting the result as an overlay; it does not inject code into Wow.exe. It is not frame generation and does not have access to native game depth or motion vectors. Keep the application outside the WoW directory. No third-party tool can guarantee compliance with game rules or account safety.

RTX 20 support is experimental and **untested on hardware**. RTX 30 support is experimental; the 310.9.16 V8b runtime was previously observed on an RTX 3080 Ti. The V8b SHA-256 is `e92cb312684e4c5f34d34dbbc7510aa83f57218c4ac101fe1b4d505e5d268f59`. RTX 40 uses the Ada-patched 310.8.0 runtime; RTX 50 can use stock 310.9.16 or the Ada-patched runtime.

Download and extract the release outside the game folder. The release includes the executables, ReShade and RenoDX, but **no NVIDIA runtime DLLs**. Supply your own compatible `nvngx_dlssnr.dll` using the manager's **Setup** page; `nvngx_dlss.dll` is optional for the experimental upscaling path. Start WoW in borderless windowed mode and select **Start overlay**, or press `Ctrl+Alt+S`. The neural pass runs at capture resolution: the advisory matrix does not automatically downscale it.

### Build

Windows 11 x64, Visual Studio 2022 with C++20, Windows SDK with `dxc`, CMake 3.28+, the NVIDIA DLSS SDK and the NVIDIA Optical Flow SDK D3D12 headers are required. Configure with `-DSIDECAR_REQUIRE_SDKS=ON -DDLSS_SDK_DIR=<path> -DNVOF_SDK_DIR=<path>`, then build the `wowsidecar` and `wowsidecar-manager` targets in Release mode. CMake fetches Dear ImGui, toml++ and Catch2 unless their FetchContent source paths are supplied locally. Use `tools/package_release.ps1` with the compiled binaries and separately obtained ReShade/RenoDX binaries to create the public archive. Source is MIT licensed; third-party components retain their own terms: [notices](THIRD-PARTY-NOTICES.md), [licenses](licenses/).
