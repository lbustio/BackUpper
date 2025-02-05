# Backup and Compression Utility

Este proyecto es una aplicación de escritorio desarrollada en Delphi que permite realizar copias de seguridad de archivos y carpetas, con la opción de comprimirlos en un archivo ZIP. La aplicación permite visualizar la estructura de directorios y realizar la copia de archivos de manera fácil y rápida.

## Funcionalidades

- **Selección de Directorios**: Permite seleccionar las carpetas de origen y destino mediante un cuadro de diálogo de selección de directorios.
- **Visualización de Archivos**: Muestra la estructura de archivos y carpetas del directorio de origen en un árbol (`TreeView`).
- **Copia de Archivos**: Permite copiar todos los archivos y subcarpetas desde la carpeta de origen a la carpeta de destino.
- **Compresión de Archivos**: Permite comprimir los archivos de la carpeta de origen en un archivo ZIP en el directorio de destino.
- **Progreso de la Copia**: Muestra barras de progreso tanto para la compresión de archivos como para la copia de archivos.
- **Comentarios**: Permite agregar un archivo de texto con comentarios sobre la copia realizada.
- **Persistencia de Configuración**: Guarda las rutas de los directorios de origen y destino en un archivo `.INI` para reutilizarlas en futuras ejecuciones de la aplicación.

## Requisitos

- Delphi 7 o superior, aunque sugerido Delphi RAD Studio 12

## Instalación

1. Clona este repositorio en tu máquina local:
   ```bash
   git clone https://github.com/lbustio/BackUpper.git
   ```
2. Abre el proyecto en Delphi.

3. Asegúrate de que tienes todos los componentes necesarios instalados. 

4. Compila y ejecuta el proyecto.


## Uso

1. Al iniciar la aplicación, puedes elegir la carpeta de origen y la carpeta de destino haciendo clic en los botones "Seleccionar carpeta Fuente" y "Seleccionar carpeta Destino".
2. Puedes elegir si deseas comprimir los archivos de la carpeta de origen seleccionando la casilla "Comprimir".
3. Una vez configurados los directorios y la opción de compresión, haz clic en el botón "Realizar Copia de Seguridad" para copiar o comprimir los archivos.
4. El progreso de la copia o compresión se mostrará en las barras de progreso.
5. Si no has seleccionado la opción de compresión, los archivos se copiarán directamente. Si la compresión está activada, se creará un archivo ZIP con los archivos seleccionados.
6. Se guardará un archivo Leeme.txt en la carpeta de destino con los comentarios, si los has ingresado en la aplicación.

## Estructura del Proyecto

```pascal
- FrmPrincipal.pas      # Código principal de la aplicación
- backup-compression-utility.dproj # Proyecto Delphi
```

## Contribuciones

Las contribuciones son bienvenidas. Si deseas mejorar o agregar funcionalidades, por favor abre un `pull request` o un `issue` en GitHub.

## Licencia
Este proyecto está bajo la Licencia MIT. Para más detalles, consulta el archivo LICENSE.