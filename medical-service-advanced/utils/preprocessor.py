"""
Medical Text Preprocessor
"""

from typing import List, Optional
import re

class MedicalPreprocessor:
    def process(self, text: str, symptoms: Optional[List[str]] = None, age: Optional[int] = None) -> str:
        """Procesar texto médico"""
        processed = text.strip()
        
        if symptoms:
            symptoms_text = ", ".join(symptoms)
            processed = f"{processed}. Síntomas: {symptoms_text}"
        
        if age:
            processed = f"{processed}. Edad: {age} años"
        
        return processed