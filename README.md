# カモタカツノミノカモ

A SAT-based nonogram solver.

## Comenzando :rocket: (Linux)

Para instalar el programa, es necesario tener instalado `ruby` versión 3.2.2 o superior, no se asegura el correcto funcionamiento en versiones anteriores.

Para clonar el repositorio:

```bash
git clone --recursive https://github.com/chrischriscris/kamotaketsunominokamo.git
```

Luego, en la carpeta raíz del repositorio:

```bash
source install.sh # o . install.sh
```

Si hay algún problema con la instalación, pruebe a clonar nuevamente el repositorio en un directorio distinto. Asegúrese de que la nueva ubicación no tenga espacios en el nombre, debido a que un submódulo de la instalación no funciona correctamente en ubicaciones con espacios en el nombre.

Otro error que puede suceder durante la instalación, es la falta de permisos para instalar las dependencias de `ruby` en la raíz del sistema. Para evitar esto, se recomienda usar un manejador de versiones como `RVM` o `rbenv`, para instalar `ruby` en un directorio local.

## CLI Uso

Una vez instalado el programa, se puede ejecutar desde cualquier directorio mientras se esté en la misma sesión de terminal:

```bash
kamotake <input_file> -d -c
```

siendo `input_file` el archivo de entrada que describe el problema en el formato especificado más abajo, y los flags opcionales `-d` para mantener los archivos DIMACS y CNF generados, y `-c` para mostrar el resultado compacto.

| ![CLI](./img/cli1.png) | ![CLI](./img/cli2.png) |
| ---------------------- | ---------------------- |
| Sin compactar          | Compactado             |

## Kamotake Web

![Kamotake Web](./img/web1.jpeg)

O para ejecutar la interfaz web, se debe ejecutar desde la carpeta raíz del repositorio:

```bash
./run-kamotake-server.sh
```

Luego, se puede acceder a la interfaz web desde el navegador en la dirección `localhost:12345`.

Para solicitar una orden (la recomendación del chef), haga click en el botón `Nonogram (Chef's Recommendation)`.

![Kamotake Web](./img/web2.png)

Luego, suba un ingrediente con el formato de entrada indicada en la sección siguiente, y haga click en el botón `Order now!`. El resultado se mostrará en la parte inferior de la página.

![Kamotake Web](./img/web3.jpeg)

## Formato de entrada

Se utiliza un archivo de texto plano para describir el problema. El archivo contiene un solo objeto con los siguientes campos:

```txt
<number_of_columns> <number_of_rows>
<row_1>
<row_2>
...
<row_number_of_rows>
<column_1>
<column_2>
...
<column_number_of_columns>
```

donde cada fila y columna se describe como una lista de números separados por un espacio, que representan la cantidad de celdas consecutivas que deben estar pintadas en esa fila o columna.

## Informe

El informe se encuentra en la carpeta `results`.

---

Made with :heart: by [Chus](https://www.github.com/chrischriscris) and [K](https://www.github.com/fungikami)
