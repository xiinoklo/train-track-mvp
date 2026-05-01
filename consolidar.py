import os

# Ajusta las extensiones según lo que uses en tu MVP
EXTENSIONES_VALIDAS = ('.py', '.js', '.jsx', '.ts', '.tsx', '.json', '.html', '.css', '.md')
# Carpetas que son basura para el análisis
CARPETAS_IGNORADAS = {'node_modules', '.git', 'venv', 'env', '__pycache__', 'dist', 'build', '.next'}
ARCHIVO_SALIDA = 'proyecto_consolidado.txt'

def consolidar_proyecto(ruta_base):
    with open(ARCHIVO_SALIDA, 'w', encoding='utf-8') as salida:
        for raiz, directorios, archivos in os.walk(ruta_base):
            # Filtrar directorios basura in-place
            directorios[:] = [d for d in directorios if d not in CARPETAS_IGNORADAS]
            
            for archivo in archivos:
                # Filtrar explícitamente archivos de variables de entorno por seguridad
                if archivo.startswith('.env'):
                    continue
                    
                if archivo.endswith(EXTENSIONES_VALIDAS):
                    ruta_completa = os.path.join(raiz, archivo)
                    ruta_relativa = os.path.relpath(ruta_completa, ruta_base)
                    
                    salida.write(f"\n\n{'='*60}\n")
                    salida.write(f"Ruta: {ruta_relativa}\n")
                    salida.write(f"{'='*60}\n\n")
                    
                    try:
                        with open(ruta_completa, 'r', encoding='utf-8') as f:
                            salida.write(f.read())
                    except Exception as e:
                        salida.write(f"[ERROR leyendo archivo: {e}]\n")

    print(f"[+] Extracción completada. Sube el archivo '{ARCHIVO_SALIDA}' al chat.")

if __name__ == '__main__':
    consolidar_proyecto('.')
