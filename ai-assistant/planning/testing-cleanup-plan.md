# Plan Integral de Testing, Cleanup y Documentación – Echos Copilot

## Objetivo Final

Implementar una infraestructura de testing robusta, modular y mantenible, utilizando Jest para JavaScript y Bats para scripts shell, con un módulo de cleanup para eliminar archivos obsoletos, y documentación clara para el equipo.

---

## Estado Actual

- Existen scripts de test en shell (`unit-tests.sh`, `integration-tests.sh`, etc.) y lógica en JS (`build.js`).
- No hay suite de Jest ni tests en formato Bats.
- No existe un script de cleanup automatizado.
- La documentación de tests es mínima o desactualizada.

---

## Módulos de Ejecución

| Nombre                         | Propósito                                                | Descripción de Contexto                                                               | Entregables                                  | Dependencias           |
| ------------------------------ | -------------------------------------------------------- | ------------------------------------------------------------------------------------- | -------------------------------------------- | ---------------------- |
| **Cleanup Script Init**        | Crear script de cleanup para borrar archivos obsoletos   | No existe utilidad de limpieza, algunos archivos quedarán obsoletos tras la migración | `cleanup.sh` o `cleanup.js`                  | Node.js o bash/zsh     |
| **Instalación de Jest y Bats** | Instalar y configurar Jest (para JS) y Bats (para shell) | No hay suites de testing modernas instaladas                                          | Jest y Bats instalados, configuración básica | Node.js, npm, bash/zsh |
| **Crear Shell Tests (Bats)**   | Portar y crear tests de shell en formato Bats            | Los tests actuales son scripts `.sh`, no Bats                                         | `tests/bats/unit-tests.bats`, etc.           | Bats, scripts shell    |
| **Crear JS Tests (Jest)**      | Crear tests en Jest para lógica JS (ej: `build.js`)      | No hay tests automatizados para JS                                                    | `tests/build.test.js`, configuración Jest    | Node.js, Jest          |
| **Agregar Documentación**      | Documentar el uso de los tests y el cleanup              | Nueva estructura dual de testing y utilidades                                         | `tests/README.md` actualizado                | Todos los anteriores   |

---

## Detalle de Acciones

1. **Cleanup Script Init**

   - Crear un script (`cleanup.sh` o `cleanup.js`) que acepte una lista de archivos a eliminar, soporte dry-run y confirmación, y registre las acciones.
   - Documentar su uso y mantener la lista de archivos a limpiar actualizada.

2. **Instalación de Jest y Bats**

   - Instalar Jest (`npm install --save-dev jest`) y Bats (`brew install bats-core` o similar).
   - Configurar ambos para integrarse en el flujo de trabajo y CI.

3. **Crear Shell Tests (Bats)**

   - Portar los scripts de test `.sh` a archivos `.bats` en `tests/bats/`.
   - Asegurar que los tests usen las variables de color centralizadas y sean modulares.

4. **Crear JS Tests (Jest)**

   - Crear archivos de test `.test.js` para los módulos JS principales (ejemplo: `build.test.js`).
   - Incluir pruebas de CLI, lógica interna y casos de error.

5. **Agregar Documentación**
   - Actualizar `tests/README.md` con instrucciones para correr ambos tipos de tests y el script de cleanup.
   - Incluir ejemplos de uso, dependencias y recomendaciones de buenas prácticas.

---

## Consideraciones de Seguridad y Mantenimiento

- El script de cleanup debe ser seguro (dry-run por defecto, confirmación antes de borrar).
- La lista de archivos a eliminar debe ser fácil de modificar y revisar.
- Los tests deben ser fácilmente ejecutables tanto localmente como en CI.

---

## Visualización de Progreso

- Se medirá por la existencia y funcionamiento de cada módulo, cobertura de tests y limpieza efectiva de archivos obsoletos.
- La documentación debe reflejar el estado actualizado del sistema de testing y mantenimiento.

---

## Siguiente Paso

- Elegir por cuál módulo comenzar (cleanup, instalación de herramientas, migración de tests, etc.) según prioridades del equipo.
