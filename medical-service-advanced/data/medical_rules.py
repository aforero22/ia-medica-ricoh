"""
Medical Rules Engine
"""

from typing import Dict, Any, List, Optional

class MedicalRulesEngine:
    def apply_rules(
        self, 
        result: Dict[str, Any], 
        patient_age: Optional[int] = None, 
        symptoms: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """Aplicar reglas médicas"""
        enhanced_result = result.copy()
        enhanced_result["rules_applied"] = []
        
        # Regla de edad para pediatría
        if patient_age and patient_age < 18:
            enhanced_result["rules_applied"].append("pediatric_consideration")
        
        # Regla de síntomas críticos
        if symptoms:
            critical_symptoms = ["dolor pecho", "dificultad respirar", "pérdida conciencia"]
            if any(symptom in " ".join(symptoms).lower() for symptom in critical_symptoms):
                enhanced_result["rules_applied"].append("critical_symptoms_detected")
        
        return enhanced_result