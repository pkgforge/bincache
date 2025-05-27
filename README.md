<div align="center">

[discord-shield]: https://img.shields.io/discord/1313385177703256064?logo=%235865F2&label=Discord
[discord-url]: https://discord.gg/djJUs48Zbu
[stars-shield]: https://img.shields.io/github/stars/pkgforge/bincache.svg
[stars-url]: https://github.com/pkgforge/bincache/stargazers
[issues-shield]: https://img.shields.io/github/issues/pkgforge/bincache.svg
[issues-url]: https://github.com/pkgforge/bincache/issues
[license-shield]: https://img.shields.io/github/license/pkgforge/bincache.svg
[license-url]: https://github.com/pkgforge/bincache/blob/main/LICENSE
[doc-shield]: https://img.shields.io/badge/docs.pkgforge.dev-blue
[doc-url]: https://docs.pkgforge.dev/repositories/bincache

<a href="https://pkgs.pkgforge.dev"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/bincache/data/TOTAL.json&query=$[2].total&label=Binaries&labelColor=orange&style=flat&link=https://pkgs.pkgforge.dev" alt="Binaries" /></a>
[![Discord][discord-shield]][discord-url]
[![Documentation][doc-shield]][doc-url]
[![Issues][issues-shield]][issues-url]
[![License: MIT][license-shield]][license-url]
[![Stars][stars-shield]][stars-url]
</div>

<p align="center">
    <b><strong> <a href="https://pkgs.pkgforge.dev">The Largest Collection of Prebuilt Static Binaries</a></code></strong></b>
    <br> 
</p>

---
- This repository [builds, compiles & bundles](https://github.com/pkgforge/bincache/actions) [SoarPkgs](https://github.com/pkgforge/soarpkgs/) & provides [PreBuilt Package Cache](https://docs.pkgforge.dev/repositories/bincache/cache) for [Soar](https://github.com/pkgforge/soar)
```bash
.
├── keys --> Public Keys to verify signed artifacts
├── scripts --> CI Build Scripts & Misc
└── SBUILD_LIST.json --> Current JSON of all the binaries that are being built
```

> [!WARNING]
> DO NOT use the Issues page to request packages or report broken binaries<br>
> All of those will be auto-closed/moved to: https://github.com/pkgforge/soarpkgs

> [!NOTE]
> We recommend cloning with [`--filter=blob:none`](https://github.blog/open-source/git/get-up-to-speed-with-partial-clone-and-shallow-clone/) for local development<br>
> Package Listing & Searching: https://pkgs.pkgforge.dev

---
#### Index
- [**📖 Docs & FAQs 📖**](https://docs.pkgforge.dev/repositories/bincache)
> - [**`What is this?`**](https://docs.pkgforge.dev/repositories/bincache)
> - [**`What are the current Cache Backends`**](https://docs.pkgforge.dev/repositories/bincache/cache)
> - [**`Contribution Guidelines`**](https://docs.pkgforge.dev/repositories/bincache/contribution)
> - [**`Request a New Package`**](https://docs.pkgforge.dev/repositories/bincache/package-request)
> - [**`Differences from Soarpkgs`**](https://docs.pkgforge.dev/repositories/bincache/differences)
> - **`Requirements to add a PKG to` [`BinCache`](https://docs.pkgforge.dev/repositories/bincache/package-request)**
> - [**`DMCA/Copyright/PKG Removal`**](https://docs.pkgforge.dev/repositories/soarpkgs/dmca-or-copyright-cease-and-desist)
> - [**`FAQs`**](https://docs.pkgforge.dev/repositories/bincache/faq)
> - [**`Security`**](https://docs.pkgforge.dev/repositories/bincache/security)
> - [**`Contact Us`**](https://docs.pkgforge.dev/contact/chat)
- [**Community 💬**](https://docs.pkgforge.dev/contact/chat)
> - <a href="https://discord.gg/djJUs48Zbu"><img src="https://github.com/user-attachments/assets/5a336d72-6342-4ca5-87a4-aa8a35277e2f" width="18" height="18"><code>PkgForge (<img src="https://github.com/user-attachments/assets/a08a20e6-1795-4ee6-87e6-12a8ab2a7da6" width="18" height="18">) Discord </code></a> `➼` [`https://discord.gg/djJUs48Zbu`](https://discord.gg/djJUs48Zbu)

---
#### Package Stats
> [!NOTE]
> ℹ️ It is usual for most packages to be outdated since we build most of them from `GIT HEAD`<br>
> 🗄️ Table of Packages & their status: https://github.com/pkgforge/metadata/blob/main/PKG_STATUS.md<br>
> 🗄️ Table of Only Outdated Packages: https://github.com/pkgforge/metadata/blob/main/soarpkgs/data/COMP_VER_CACHE_OLD.md<br>

|Total Packages 📦 | Updated 🟩 | Outdated 🟥 | Healthy 🟢 | Stale 🔴 |
|----------------|---------|----------|----------|---------|
| [![Packages](https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/PKG_STATUS_SUM.json&query=$[0].bincache.packages&label=&color=blue&style=flat)](#) | [![Updated](https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/PKG_STATUS_SUM.json&query=$[0].bincache.updated&label=&color=brightgreen&style=flat)](#) | [![Outdated](https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/PKG_STATUS_SUM.json&query=$[0].bincache.outdated&label=&color=red&style=flat)](#) | [![Health](https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/PKG_STATUS_SUM.json&query=$[0].bincache.healthy&label=&suffix=%25&color=green&style=flat)](#) | [![Stale](https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/PKG_STATUS_SUM.json&query=$[0].bincache.stale&label=&suffix=%25&color=orange&style=flat)](#) |

---
#### Repo Analytics
[![Alt](https://repobeats.axiom.co/api/embed/2ddc6c95e39c4faa970897442245e76156c45167.svg "Repobeats analytics image")](https://github.com/pkgforge/bincache/graphs/contributors)
[![Stargazers](https://reporoster.com/stars/dark/pkgforge/bincache)](https://github.com/pkgforge/bincache/stargazers)
[![Stargazers over time](https://starchart.cc/pkgforge/bincache.svg?variant=dark)](https://starchart.cc/pkgforge/bincache)
<div align="center">
