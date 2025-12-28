# Como Adicionar o Ícone do App

## Opção 1: Usando o Script Python (Recomendado)

Se você tem uma imagem de alta resolução (preferencialmente 1024x1024 ou maior) do ícone:

1. Instale o Pillow (se ainda não tiver):
   ```bash
   pip3 install Pillow
   ```

2. Execute o script:
   ```bash
   cd macos
   python3 generate_icons.py <caminho_para_sua_imagem.png>
   ```

   Exemplo:
   ```bash
   python3 generate_icons.py ~/Downloads/app_icon.png
   ```

O script irá gerar automaticamente todos os tamanhos necessários (16x16, 32x32, 64x64, 128x128, 256x256, 512x512, 1024x1024) e colocá-los no diretório correto.

## Opção 2: Manualmente

Se preferir fazer manualmente ou não tiver Python/Pillow:

1. Prepare sua imagem do ícone em alta resolução (1024x1024 ou maior)

2. Gere os seguintes tamanhos:
   - 16x16 pixels → `app_icon_16.png`
   - 32x32 pixels → `app_icon_32.png`
   - 64x64 pixels → `app_icon_64.png`
   - 128x128 pixels → `app_icon_128.png`
   - 256x256 pixels → `app_icon_256.png`
   - 512x512 pixels → `app_icon_512.png`
   - 1024x1024 pixels → `app_icon_1024.png`

3. Substitua os arquivos em:
   ```
   macos/Runner/Assets.xcassets/AppIcon.appiconset/
   ```

4. Certifique-se de que os arquivos estão em formato PNG com fundo transparente (se necessário)

## Verificação

Após adicionar os ícones, você pode verificar se estão corretos executando:

```bash
flutter clean
flutter pub get
flutter build macos
```

O ícone aparecerá no Finder e no Dock quando você executar o app.

