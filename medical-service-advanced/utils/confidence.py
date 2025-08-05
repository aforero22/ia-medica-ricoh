"""
Confidence Scorer
"""

from typing import Dict, Any, List

class ConfidenceScorer:
    def calculate_final_confidence(
        self, 
        predictions: Dict[str, Any], 
        ensemble_confidence: float, 
        rules_applied: List[str] = None
    ) -> float:
        """Calcular confianza final"""
        base_confidence = ensemble_confidence
        
        # Ajustar por número de modelos que coinciden
        if len(predictions) > 1:
            base_confidence *= 1.1
        
        # Ajustar por reglas aplicadas
        if rules_applied:
            base_confidence *= 1.05
        
        return min(base_confidence, 1.0)