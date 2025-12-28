#!/usr/bin/env python3
"""
Script para gerar os ícones do app em diferentes tamanhos a partir de uma imagem de alta resolução.
Uso: python3 generate_icons.py <caminho_para_imagem_original.png>
"""

import sys
import os
from PIL import Image

def generate_icons(source_image_path):
    """Gera todos os tamanhos de ícone necessários para macOS."""
    
    # Tamanhos necessários para macOS
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    
    # Diretório de destino
    output_dir = "Runner/Assets.xcassets/AppIcon.appiconset"
    
    if not os.path.exists(output_dir):
        print(f"Erro: Diretório {output_dir} não encontrado!")
        return False
    
    try:
        # Abrir a imagem original
        img = Image.open(source_image_path)
        
        # Converter para RGBA se necessário
        if img.mode != 'RGBA':
            img = img.convert('RGBA')
        
        print(f"Gerando ícones a partir de: {source_image_path}")
        print(f"Tamanho original: {img.size}")
        
        # Gerar cada tamanho
        for size in sizes:
            # Redimensionar mantendo proporção
            resized = img.resize((size, size), Image.Resampling.LANCZOS)
            
            # Nome do arquivo
            filename = f"app_icon_{size}.png"
            filepath = os.path.join(output_dir, filename)
            
            # Salvar
            resized.save(filepath, "PNG", optimize=True)
            print(f"✓ Gerado: {filename} ({size}x{size})")
        
        print("\n✓ Todos os ícones foram gerados com sucesso!")
        print(f"Localização: {output_dir}")
        return True
        
    except FileNotFoundError:
        print(f"Erro: Arquivo {source_image_path} não encontrado!")
        return False
    except Exception as e:
        print(f"Erro ao processar imagem: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Uso: python3 generate_icons.py <caminho_para_imagem_original.png>")
        print("\nExemplo:")
        print("  python3 generate_icons.py ~/Downloads/app_icon.png")
        sys.exit(1)
    
    source_image = sys.argv[1]
    
    if not os.path.exists(source_image):
        print(f"Erro: Arquivo {source_image} não encontrado!")
        sys.exit(1)
    
    success = generate_icons(source_image)
    sys.exit(0 if success else 1)

