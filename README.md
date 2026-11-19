**[🇷🇺 Русский](#russian) | [🇬🇧 English](#english)**

---

<a id="russian"></a>
## 🇷🇺 Русский

# 🧊 ComfyUI-Hi3D-OreX

Набор изолированных узлов для запуска **Hi3D v1.0** в ComfyUI. Hi3D уточняет существующую грубую 3D-геометрию по исходному изображению и создаёт детализированный mesh с разрешением 512, 1024 или 1536.

Все узлы имеют собственные идентификаторы `_ox`, отображаемые имена заканчиваются на `-ox`, а встроенная библиотека работает в пространстве имён `sparc3d_orex`. Поэтому пакет можно устанавливать рядом с другими реализациями Hi3D без конфликта узлов и Python-модулей.

> Hi3D не создаёт форму с нуля. Ему необходимы исходное изображение и базовая 3D-модель из TRELLIS.2, Pixal3D, Hunyuan3D, TripoSG или другого генератора.

### Купить кофе разработчику: ☕ ☕ ☕

Сообщайте о найденных проблемах — постараемся их исправить.

Поддержать проект: ❤️❤️❤️ **[D O N A T](https://www.donationalerts.com/r/orex2121)** ❤️❤️❤️

### ⚒️ Автор адаптации ⚒️

- OreX (Олег К.)

### 📋 Меню узлов

`1.` [📦 Hi3D Load Model-ox](#ru-1-hi3d-load-model)  
`2.` [🧊 Hi3D Refine-ox](#ru-2-hi3d-refine)  
`3.` [💾 Hi3D Export-ox](#ru-3-hi3d-export)  
`4.` [🔄 Comfy MESH to TRIMESH-ox](#ru-4-mesh-to-trimesh)  

### 📝 Описание узлов

<a id="ru-1-hi3d-load-model"></a>
#### 1. 📦 Hi3D Load Model-ox

Загружает основной pipeline Hi3D и два image-encoder.

**Узел поддерживает:**

- основной набор весов `Hi3Dv1.0`;
- `facebook/dinov2-large` и `openai/clip-vit-large-patch14`;
- `model_swap` — рекомендуемый режим с переносом выполняемой части на GPU;
- `gpu_resident` — максимальная скорость при достаточном объёме VRAM;
- `sequential_offload` — минимальный расход VRAM, но медленнее;
- автоматическое скачивание моделей через `auto_download`;
- кеширование pipeline между запусками;
- отдельный тип выхода `HI3D_MODEL_OX`.

<a id="ru-2-hi3d-refine"></a>
#### 2. 🧊 Hi3D Refine-ox

Уточняет грубую 3D-модель по исходному изображению и возвращает детализированный `TRIMESH`.

**Узел поддерживает:**

- входы `HI3D_MODEL_OX`, `IMAGE`, `TRIMESH` и необязательную `MASK`;
- разрешения 512 — один проход, 1024 — два, 1536 — три;
- планировщики `heun` и `euler`;
- image guidance и настройку sparse voxel budget;
- tiled VAE decode для уменьшения расхода VRAM;
- упрощение mesh, удаление мелких компонентов и заполнение отверстий;
- восстановление масштаба исходного mesh;
- освобождение моделей после выполнения.

Рекомендуемые настройки для **TRELLIS.2 512 → Hi3D 1024**:

| Параметр | Значение |
|---|---:|
| `resolution` | `1024` |
| `steps` | `25` |
| `scheduler` | `heun` |
| `guidance_strength` | `1.0` |
| `guidance_cutoff` | `0.7` |
| `voxel_budget_scale` | `1.0–1.5` |
| `tiled_decode` | `true` |
| `reduce_faces` | `true` |
| `target_face_count` | `0` — около 1 млн граней |
| `sigma_min` | `0.002` |
| `time_rescale_factor` | `2.0` |

> Маска от нативного `Remove Background` уже использует белый цвет для объекта — оставляйте `invert_mask: false`. Включайте его только для инвертированной маски с выхода стандартного `Load Image`.

<a id="ru-3-hi3d-export"></a>
#### 3. 💾 Hi3D Export-ox

Сохраняет `TRIMESH` в `ComfyUI/output` в формате GLB, OBJ, PLY или STL. Возвращает относительный путь к файлу для подключения к 3D Preview.

<a id="ru-4-mesh-to-trimesh"></a>
#### 4. 🔄 Comfy MESH to TRIMESH-ox

Преобразует нативный батчированный тип `MESH` ComfyUI в `trimesh.Trimesh` (`TRIMESH`). Позволяет подключать `VAE Decode Shape`, TRELLIS.2, Pixal3D и другие нативные 3D-узлы к `Hi3D Refine-ox`.

### 🔗 Рекомендуемое подключение

```text
TRELLIS.2 Shape Stage 512
        ↓
VAE Decode Shape
        ↓
Comfy MESH to TRIMESH-ox
        ↓
Hi3D Refine-ox (1024)
        ↓
Hi3D Export-ox
```

Для связки **TRELLIS.2 512 + Hi3D 1024** передавайте в Hi3D латент базовой 512-стадии до `Trellis2 Upsample Stage`. Не используйте уже повышенную до 1536 геометрию как вход этой ветки.

### 📥 Установка

1. Скопируйте папку в:

   ```text
   📂 ComfyUI/
   └─ 📂 custom_nodes/
      └─ 📂 ComfyUI-Hi3D-OreX/
   ```

2. Для **Portable ComfyUI на Windows** запустите двойным щелчком:

   ```text
   Install.bat
   ```

   Установщик использует только `python_embeded` этой portable-сборки, определяет CUDA из установленного PyTorch и ставит совместимые `cumm`/`spconv` для `cu126`, `cu128` или `cu130`. Сам PyTorch он не устанавливает и не заменяет.

   Для ручной установки обычных Python-зависимостей:

   ```bash
   python -m pip install -r requirements.txt
   ```

3. Для работы также нужны `flash-attn` и Triton, которые обычно уже устанавливаются вместе с TRELLIS.2. Не заменяйте PyTorch из готовой portable-сборки ComfyUI.

4. Полностью перезапустите ComfyUI.

### 🧠 Модели

| Модель | Hugging Face | Папка |
|---|---|---|
| Hi3D v1.0 | [hi3d-official/Hi3Dv1.0](https://huggingface.co/hi3d-official/Hi3Dv1.0) | `models/hi3d/Hi3Dv1.0/` |
| DINOv2 Large | [facebook/dinov2-large](https://huggingface.co/facebook/dinov2-large) | `models/hi3d/dinov2-large/` |
| CLIP ViT-L/14 | [openai/clip-vit-large-patch14](https://huggingface.co/openai/clip-vit-large-patch14) | `models/hi3d/clip-vit-large-patch14/` |

При `auto_download: true` модели скачиваются автоматически. Для автономной установки разместите их заранее:

```text
📂 ComfyUI/
└─ 📂 models/
   └─ 📂 hi3d/
      ├─ 📂 Hi3Dv1.0/
      │  ├─ model_index.json
      │  ├─ 📂 scheduler/
      │  │  └─ scheduler_config.json
      │  ├─ 📂 transformer_512/
      │  │  ├─ config.json
      │  │  └─ model.safetensors
      │  ├─ 📂 transformer_1024/
      │  │  ├─ config.json
      │  │  └─ model.safetensors
      │  └─ 📂 vae/
      │     ├─ config.json
      │     └─ model.safetensors
      ├─ 📂 dinov2-large/
      │  ├─ config.json
      │  └─ model.safetensors
      └─ 📂 clip-vit-large-patch14/
         ├─ config.json
         └─ model.safetensors
```

### 🖥️ Требования

- NVIDIA GPU с CUDA и compute capability 8.0 или новее;
- CPU-режим не поддерживается;
- для 1024 рекомендуется от 16 ГБ VRAM либо `model_swap` + `tiled_decode`;
- 1536 требует значительно больше времени, RAM и VRAM.

Готовый пример находится в [`example_workflows/Hi3Dv1.0 - workflow.json`](example_workflows/Hi3Dv1.0%20-%20workflow.json).

---

<a id="english"></a>
## 🇬🇧 English

# 🧊 ComfyUI-Hi3D-OreX

A conflict-free ComfyUI node pack for **Hi3D v1.0**. Hi3D refines an existing coarse 3D mesh against its reference image and returns detailed geometry at resolution 512, 1024, or 1536.

Every node has a private `_ox` identifier, every display name ends in `-ox`, and the bundled inference library uses the isolated `sparc3d_orex` namespace. Other Hi3D implementations can therefore be installed alongside this pack without node or Python-module collisions.

> Hi3D is not a shape generator. It needs a reference image and a coarse mesh produced by TRELLIS.2, Pixal3D, Hunyuan3D, TripoSG, or another generator.

### Buy the developer a coffee: ☕ ☕ ☕

Let us know if you encounter a problem and we will try to fix it.

Support the project: ❤️❤️❤️ **[D O N A T](https://www.donationalerts.com/r/orex2121)** ❤️❤️❤️

### ⚒️ Adaptation author ⚒️

- OreX (Oleg K.)

### 📋 Node menu

`1.` [📦 Hi3D Load Model-ox](#en-1-hi3d-load-model)  
`2.` [🧊 Hi3D Refine-ox](#en-2-hi3d-refine)  
`3.` [💾 Hi3D Export-ox](#en-3-hi3d-export)  
`4.` [🔄 Comfy MESH to TRIMESH-ox](#en-4-mesh-to-trimesh)  

### 📝 Node descriptions

<a id="en-1-hi3d-load-model"></a>
#### 1. 📦 Hi3D Load Model-ox

Loads the Hi3D pipeline and its image encoders.

**The node supports:**

- `Hi3Dv1.0`, `facebook/dinov2-large`, and `openai/clip-vit-large-patch14`;
- `model_swap`, `gpu_resident`, and `sequential_offload` VRAM modes;
- automatic model download and pipeline caching;
- a private `HI3D_MODEL_OX` output type.

<a id="en-2-hi3d-refine"></a>
#### 2. 🧊 Hi3D Refine-ox

Refines a coarse mesh against its source image and returns a detailed `TRIMESH`.

**The node supports:**

- `HI3D_MODEL_OX`, `IMAGE`, `TRIMESH`, and optional `MASK` inputs;
- 512 (one pass), 1024 (two passes), and 1536 (three passes);
- Heun and Euler schedulers;
- configurable image guidance and sparse voxel budget;
- tiled VAE decoding, simplification, component removal, and hole filling;
- source-bound restoration and automatic model offload.

Recommended settings for **TRELLIS.2 512 → Hi3D 1024**:

| Setting | Value |
|---|---:|
| `resolution` | `1024` |
| `steps` | `25` |
| `scheduler` | `heun` |
| `guidance_strength` | `1.0` |
| `guidance_cutoff` | `0.7` |
| `voxel_budget_scale` | `1.0–1.5` |
| `tiled_decode` | `true` |
| `reduce_faces` | `true` |
| `target_face_count` | `0` — about 1M faces |
| `sigma_min` | `0.002` |
| `time_rescale_factor` | `2.0` |

> Native `Remove Background` already returns a white-foreground mask, so keep `invert_mask: false`. Enable it only for the inverted mask returned by standard `Load Image`.

<a id="en-3-hi3d-export"></a>
#### 3. 💾 Hi3D Export-ox

Exports a `TRIMESH` into `ComfyUI/output` as GLB, OBJ, PLY, or STL and returns its relative path.

<a id="en-4-mesh-to-trimesh"></a>
#### 4. 🔄 Comfy MESH to TRIMESH-ox

Converts ComfyUI's native batched `MESH` into `trimesh.Trimesh` (`TRIMESH`) for direct use with `Hi3D Refine-ox`.

### 🔗 Recommended connection

```text
TRELLIS.2 Shape Stage 512
        ↓
VAE Decode Shape
        ↓
Comfy MESH to TRIMESH-ox
        ↓
Hi3D Refine-ox (1024)
        ↓
Hi3D Export-ox
```

Feed Hi3D from the base 512 shape latent before `Trellis2 Upsample Stage`. Do not use the already upsampled 1536 geometry as the input to this branch.

### 📥 Installation

1. Copy the pack into `ComfyUI/custom_nodes/ComfyUI-Hi3D-OreX/`.
2. On **Portable ComfyUI for Windows**, double-click:

   ```text
   Install.bat
   ```

   The installer uses only that portable build's `python_embeded`, detects CUDA from its installed PyTorch, and installs matching `cumm`/`spconv` packages for `cu126`, `cu128`, or `cu130`. It does not install or replace PyTorch.

   To install the regular Python requirements manually:

   ```bash
   python -m pip install -r requirements.txt
   ```

3. `flash-attn` and Triton are also required and are normally installed with TRELLIS.2. Do not replace the PyTorch bundled with a portable ComfyUI build.
4. Fully restart ComfyUI.

### 🧠 Models

| Model | Hugging Face | Folder |
|---|---|---|
| Hi3D v1.0 | [hi3d-official/Hi3Dv1.0](https://huggingface.co/hi3d-official/Hi3Dv1.0) | `models/hi3d/Hi3Dv1.0/` |
| DINOv2 Large | [facebook/dinov2-large](https://huggingface.co/facebook/dinov2-large) | `models/hi3d/dinov2-large/` |
| CLIP ViT-L/14 | [openai/clip-vit-large-patch14](https://huggingface.co/openai/clip-vit-large-patch14) | `models/hi3d/clip-vit-large-patch14/` |

With `auto_download: true`, the models are downloaded automatically. The directory tree is identical to the Russian section above.

### 🖥️ Requirements

- NVIDIA CUDA GPU with compute capability 8.0 or newer;
- no CPU execution path;
- 16 GB VRAM or more is recommended for 1024, or use `model_swap` with `tiled_decode`;
- 1536 requires substantially more time, RAM, and VRAM.

The complete example is included at [`example_workflows/Hi3Dv1.0 - workflow.json`](example_workflows/Hi3Dv1.0%20-%20workflow.json).

---

## 📜 License and credits

The nodes are adapted from [Rizzlord/ComfyUI-Hi3D](https://github.com/Rizzlord/ComfyUI-Hi3D) and use the official [Hi3D v1.0](https://github.com/hi3d-official/Hi3Dv1.0) inference code.

Hi3D code and weights are covered by the Hi3D Open License Agreement v1.0. Commercial integrations must display **Powered by Hi3D 1.0**. Third-party licenses are preserved in `LICENSE`, `NOTICE`, `AUTHORS`, `THIRD_PARTY_LICENSES.md`, and `Hi3D-1.0/sparc3d_orex/ops/flexicubes/LICENSE.txt`.

___
**by OreX — Powered by Hi3D 1.0**
