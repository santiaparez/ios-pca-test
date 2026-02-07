# PCA Study

App iOS (SwiftUI, iOS 17+) para estudiar bancos de preguntas tipo examen desde PDF escaneado u otros formatos locales.

## Cómo importar PDF/JSON

1. Abre la pestaña **Inicio**.
2. Pulsa **Importar PDF** o **Importar JSON**.
3. Selecciona el archivo desde Files.
4. Espera el resumen de importación (total, con respuesta detectada, pendientes de revisión).

### Formato JSON esperado

```json
{
  "title": "Banco PCA",
  "questions": [
    {
      "id": "1",
      "category": "Aerodinámica básica",
      "prompt": "...",
      "choices": [
        {"key": "A", "text": "..."},
        {"key": "B", "text": "..."},
        {"key": "C", "text": "..."}
      ],
      "answerKey": "B",
      "explanation": "..."
    }
  ]
}
```

## Limitaciones del OCR

- El OCR no detecta negritas; si el PDF marca la respuesta correcta solo con formato visual, la respuesta puede quedar sin definir.
- El parser intenta inferir la respuesta si encuentra frases tipo **"Respuesta: X"** o **"La respuesta (X)"**.
- Las preguntas sin respuesta detectada se marcan como **pendientes de revisión**.

## Cómo corregir preguntas sin respuesta

1. Abre la pregunta en el listado de categorías o repaso.
2. Pulsa **Editar**.
3. Selecciona la opción correcta y guarda.

## Recursos de ejemplo

- `PCAStudy/Resources/SampleQuestions.json` incluye un ejemplo de banco JSON.
