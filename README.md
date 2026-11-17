#  Proyecto APIs Flutter Separadas – 2 APIs + 2 Apps + SQLite Compartida

Proyecto en el Escritorio: `C:\Users\romev\OneDrive\Desktop\proyecto_apis_flutter_separadas`

---

##  Arquitectura del Proyecto

Cada API y cada App Flutter corren **de forma completamente independiente** pero **comparten la misma base de datos SQLite** (`alarmas.db` del examen UTH).

```
proyecto_apis_flutter_separadas/
│
├── api_saludo/          ← API 1 REST en C# .NET (puerto 5238 por separado)
├── api_doble/           ← API 2 REST en C# .NET (puerto 5238 por separado)
│
├── app_saludo/          ← App Flutter 1: Saludo Personalizado
└── app_doble/           ← App Flutter 2: Duplicador de Número
```

---

## 🔗 Enlace a la misma Base de Datos SQLite

Ambas APIs se conectan automáticamente a:
```
C:\Users\romev\OneDrive\Desktop\examen_alarma_fullstack\backend\alarmas.db
```
*(Si no existe, se crea una BD local en la carpeta de la API)*

| Tabla          | Quién escribe     | Contenido                        |
|----------------|-------------------|----------------------------------|
| `Alarma`       | Examen UTH        | Alarmas periódicas               |
| `Saludos`      | API 1 (puerto 5238) | Nombres y saludos generados    |
| `CalculosDoble`| API 2 (puerto 5238) | Números y sus dobles calculados|

---

##  Pasos para Ejecutar (3 formas)

>  **Nota Importante:** Como ambas APIs están configuradas en el puerto **5238**, se ejecutan **por separado**. Los scripts liberan automáticamente el puerto 5238 antes de iniciar.

### FORMA 1: Doble clic en scripts `.bat`

| Script                              | Acción                                        |
|-------------------------------------|-----------------------------------------------|
| `1_iniciar_API_SALUDO.bat`          | Inicia API 1 en puerto 5238 + abre Chrome     |
| `2_iniciar_API_DOBLE.bat`           | Inicia API 2 en puerto 5238 + abre Chrome     |
| `3_iniciar_EMULADOR_ANDROID_28.bat` | Arranca el Emulador Android 9 (API 28)        |
| `4_flutter_SALUDO_chrome.bat`       | Ejecuta App Saludo en Chrome                  |
| `5_flutter_DOBLE_chrome.bat`        | Ejecuta App Doble en Chrome                   |
| `6_flutter_SALUDO_android.bat`      | Ejecuta App Saludo en Emulador Android        |
| `7_flutter_DOBLE_android.bat`       | Ejecuta App Doble en Emulador Android         |
| `8_abrir_SWAGGER_y_VISOR_chrome.bat`| Abre Swagger y Visor SQLite (puerto 5238)     |
| `9_consultar_SQLITE_consola.bat`    | Muestra las 3 tablas en la terminal           |

---

### FORMA 2: VS Code con F5

Abre la carpeta `proyecto_apis_flutter_separadas` en VS Code, luego en **Run & Debug** (`Ctrl+Shift+D`):

| Configuración                          | Descripción                                |
|----------------------------------------|--------------------------------------------|
| `API 1 – Saludo (puerto 5238)`         | Inicia solo la API de Saludo               |
| `API 2 – Doble (puerto 5238)`          | Inicia solo la API de Doble                |
| `App Saludo – Chrome (puerto 8081)`    | Flutter App Saludo en Chrome               |
| `App Doble – Chrome (puerto 8082)`     | Flutter App Doble en Chrome                |
| `App Saludo – Android Emulador (API 28)` | Flutter App Saludo en Android            |
| `App Doble – Android Emulador (API 28)`  | Flutter App Doble en Android             |
| **FULL: API Saludo + App Saludo Chrome** | API 1 + App Saludo en Chrome           |
| **FULL: API Doble + App Doble Chrome**   | API 2 + App Doble en Chrome             |
| **FULL: API Saludo + App Saludo Android**| API 1 + App Saludo en Android          |
| **FULL: API Doble + App Doble Android**  | API 2 + App Doble en Android            |

---

### FORMA 3: Terminal manual

```bash
# API 1 – Saludo (en una terminal)
cd api_saludo
dotnet run --urls http://0.0.0.0:5238

# API 2 – Doble (en una terminal separada)
cd api_doble
dotnet run --urls http://0.0.0.0:5238
```

# App Flutter Saludo (en otra terminal)
cd app_saludo
flutter run -d chrome --web-port 8081
# o para Android:
flutter run -d android_lite_28

# App Flutter Doble (en otra terminal)
cd app_doble
flutter run -d chrome --web-port 8082
# o para Android:
flutter run -d android_lite_28
```

---

## 🌐 URLs Importantes (Puerto 5238)

| Recurso                        | URL (Ejecutadas por separado)            |
|--------------------------------|------------------------------------------|
| Swagger API (activa)           | http://localhost:5238/swagger            |
| Visor SQLite API (activa)      | http://localhost:5238/visor              |
| App Saludo en Chrome           | http://localhost:8081                    |
| App Doble en Chrome            | http://localhost:8082                    |
| API activa desde Android Emulador | http://10.0.2.2:5238                  |

---

##  Consola de Salida (lo que verás en Debug Console de VS Code)

### App Saludo – al presionar "Presionar para Saludar":
```
════════════════════════════════════════════════════
>>> [CONSOLA FLUTTER – APP SALUDO] SALUDO PERSONALIZADO:
>>> ¡Hola, Rome! Bienvenido. Saludo personalizado generado correctamente.
>>> ID SQLite: #3
════════════════════════════════════════════════════
```

### App Doble – al presionar "Presionar para Calcular el Doble":
```
════════════════════════════════════════════════════
>>> [CONSOLA FLUTTER – APP DOBLE] DOBLE DE UN NÚMERO:
>>> Número ingresado: 15
>>> El doble del número es: 30
>>> ID SQLite: #2
════════════════════════════════════════════════════
```

---

## 🔧 Consultar SQLite desde la Terminal de VS Code (Ctrl+Shift+P → Tasks)

```bash
# Ver todos los saludos guardados
cd api_saludo
dotnet run -- query "SELECT * FROM Saludos"

# Ver todos los cálculos de doble guardados
cd api_doble
dotnet run -- query "SELECT * FROM CalculosDoble"

# Ver las alarmas del examen
cd api_saludo
dotnet run -- query "SELECT * FROM Alarma"
```
