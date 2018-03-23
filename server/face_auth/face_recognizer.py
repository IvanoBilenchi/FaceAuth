import cv2


class FaceRecognizer:
    """Face recognizer."""

    # Public methods

    def __init__(self, model_path: str, threshold: float = 15.0) -> None:
        """Initializes a new face recognizer."""
        self.__face_classifier: cv2.face_LBPHFaceRecognizer = cv2.face.LBPHFaceRecognizer_create()
        self.__face_classifier.read(model_path)
        self.__recognition_threshold: float = threshold

    def confidence_of_prediction(self, face_path: str) -> float:
        """Returns the confidence that a face image matches that of the person the model was trained on."""
        img = cv2.imread(face_path, cv2.IMREAD_GRAYSCALE)
        label, confidence = self.__face_classifier.predict(img)
        return confidence if label == 0 else float('inf')

    def predict(self, face_path: str) -> bool:
        """Checks whether a face image matches that of the person the model was trained on."""
        return self.confidence_of_prediction(face_path) < self.__recognition_threshold
