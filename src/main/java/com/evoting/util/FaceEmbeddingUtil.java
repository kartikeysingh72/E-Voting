package com.evoting.util;

import ai.djl.inference.Predictor;
import ai.djl.ndarray.NDArray;
import ai.djl.ndarray.NDList;
import ai.djl.ndarray.NDManager;
import ai.djl.ndarray.types.DataType;
import ai.djl.ndarray.types.Shape;
import ai.djl.repository.zoo.ModelNotFoundException;
import ai.djl.repository.zoo.ZooModel;
import ai.djl.translate.Batchifier;
import ai.djl.translate.Translator;
import ai.djl.translate.TranslatorContext;
import ai.djl.Model;
import ai.djl.MalformedModelException;
import com.google.gson.Gson;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Utility class for ArcFace face embedding extraction and cosine similarity verification.
 * Uses Deep Java Library (DJL) with ONNX Runtime engine.
 *
 * Preprocessing is done entirely in Java (no DJL image transforms) to avoid
 * UnsupportedOperationException from the OnnxRuntime NDArray backend.
 *
 * The model produces a 512-dimensional normalized embedding vector from a face image.
 */
public class FaceEmbeddingUtil {

    private static final int INPUT_SIZE = 112;
    private static final String MODEL_VERSION = "arcface-onnx-1.0";
    private static final Gson gson = new Gson();

    private static ZooModel<float[], float[]> model;

    /**
     * Initialize the ArcFace ONNX model. Call once at application startup.
     * @param modelPath classpath path to the .onnx file (e.g., "/models/arcface_r100.onnx")
     */
    public static synchronized void init(String modelPath) throws MalformedModelException,
            ModelNotFoundException, IOException {

        if (model != null) return;

        // Load model from classpath
        InputStream modelStream = FaceEmbeddingUtil.class.getResourceAsStream(modelPath);
        if (modelStream == null) {
            throw new IOException("ONNX model not found at classpath: " + modelPath
                + ". Please download the ArcFace model and place it at src/main/resources" + modelPath);
        }

        // Read bytes
        byte[] modelBytes = modelStream.readAllBytes();
        modelStream.close();

        // Write to a temp file (DJL Model.load requires a Path)
        Path tempModel = Files.createTempFile("arcface_", ".onnx");
        tempModel.toFile().deleteOnExit();
        Files.write(tempModel, modelBytes);

        // Create DJL Model and load from file
        Model djlModel = Model.newInstance("arcface", "OnnxRuntime");
        djlModel.load(tempModel, "arcface");

        // Wrap as ZooModel with our translator (float[] in, float[] out)
        model = new ZooModel<>(djlModel, new ArcFaceTranslator());
    }

    /**
     * Preprocess a BufferedImage into a float array ready for the ArcFace model.
     * Resizes to 112x112, normalizes with ArcFace mean/std, outputs HWC format [1, 112, 112, 3].
     */
    private static float[] preprocessImage(BufferedImage faceImage) {
        // Resize to 112x112 using Java AWT
        BufferedImage resized = new BufferedImage(INPUT_SIZE, INPUT_SIZE, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = resized.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g.drawImage(faceImage, 0, 0, INPUT_SIZE, INPUT_SIZE, null);
        g.dispose();

        // ArcFace normalization constants
        float meanR = 127.5f / 255.0f;
        float meanG = 127.5f / 255.0f;
        float meanB = 127.5f / 255.0f;
        float stdR = 128.0f / 255.0f;
        float stdG = 128.0f / 255.0f;
        float stdB = 128.0f / 255.0f;

        // Convert to normalized float array in HWC format: [1, 112, 112, 3]
        float[] data = new float[1 * INPUT_SIZE * INPUT_SIZE * 3];
        int idx = 0;
        for (int y = 0; y < INPUT_SIZE; y++) {
            for (int x = 0; x < INPUT_SIZE; x++) {
                int rgb = resized.getRGB(x, y);
                float r = ((rgb >> 16) & 0xFF) / 255.0f;
                float gVal = ((rgb >> 8) & 0xFF) / 255.0f;
                float b = (rgb & 0xFF) / 255.0f;

                // Normalize: (pixel/255 - mean) / std
                data[idx++] = (r - meanR) / stdR;
                data[idx++] = (gVal - meanG) / stdG;
                data[idx++] = (b - meanB) / stdB;
            }
        }
        return data;
    }

    /**
     * Extract a 512-dimensional face embedding from a BufferedImage.
     * @param faceImage the face image (ideally cropped to face region)
     * @return float[512] normalized embedding vector
     */
    public static float[] extractEmbedding(BufferedImage faceImage) throws Exception {
        if (model == null) {
            throw new IllegalStateException("Face model not initialized. Call init() first.");
        }

        // Preprocess entirely in Java to avoid OnnxRuntime NDArray limitations
        float[] preprocessed = preprocessImage(faceImage);

        try (Predictor<float[], float[]> predictor = model.newPredictor()) {
            return predictor.predict(preprocessed);
        }
    }

    /**
     * Verify a live face embedding against a stored embedding using cosine similarity.
     * @param stored the stored embedding (from DB)
     * @param live the live-captured embedding
     * @param threshold minimum cosine similarity to pass (recommended: 0.60)
     * @return true if cosine similarity >= threshold
     */
    public static boolean verify(float[] stored, float[] live, double threshold) {
        double similarity = cosineSimilarity(stored, live);
        return similarity >= threshold;
    }

    /**
     * Compute cosine similarity between two vectors.
     * @return similarity score in range [-1, 1]; for normalized embeddings, typically [0, 1]
     */
    public static double cosineSimilarity(float[] a, float[] b) {
        if (a.length != b.length) {
            throw new IllegalArgumentException("Embedding dimensions must match: " + a.length + " vs " + b.length);
        }
        double dotProduct = 0.0;
        double normA = 0.0;
        double normB = 0.0;
        for (int i = 0; i < a.length; i++) {
            dotProduct += a[i] * b[i];
            normA += a[i] * a[i];
            normB += b[i] * b[i];
        }
        if (normA == 0.0 || normB == 0.0) return 0.0;
        return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
    }

    /**
     * Serialize a float[] embedding to JSON string.
     */
    public static String embeddingToJson(float[] embedding) {
        return gson.toJson(embedding);
    }

    /**
     * Deserialize a JSON string back to float[] embedding.
     */
    public static float[] jsonToEmbedding(String json) {
        return gson.fromJson(json, float[].class);
    }

    /**
     * Check if the model has been successfully initialized.
     */
    public static boolean isModelLoaded() {
        return model != null;
    }

    /**
     * Get the model version string for current model.
     */
    public static String getModelVersion() {
        return MODEL_VERSION;
    }

    /**
     * Clean up model resources. Call at application shutdown.
     */
    public static synchronized void close() {
        if (model != null) {
            model.close();
            model = null;
        }
    }

    /**
     * DJL Translator that wraps a pre-processed float[] into an NDArray
     * and extracts the output embedding.
     * All image preprocessing is done in Java (not DJL) to avoid
     * OnnxRuntime NDArray UnsupportedOperationException.
     */
    private static class ArcFaceTranslator implements Translator<float[], float[]> {

        @Override
        public NDList processInput(TranslatorContext ctx, float[] input) {
            NDManager manager = ctx.getNDManager();
            // Create NDArray with shape [1, 112, 112, 3] from pre-processed float array
            NDArray ndArray = manager.create(input, new Shape(1, INPUT_SIZE, INPUT_SIZE, 3));
            return new NDList(ndArray);
        }

        @Override
        public float[] processOutput(TranslatorContext ctx, NDList list) {
            NDArray output = list.singletonOrThrow();
            // ArcFace output is [1, 512] -- extract the embedding
            float[] embedding = output.toFloatArray();
            // L2 normalize the embedding
            double norm = 0.0;
            for (float v : embedding) norm += v * v;
            norm = Math.sqrt(norm);
            if (norm > 0) {
                for (int i = 0; i < embedding.length; i++) {
                    embedding[i] = (float) (embedding[i] / norm);
                }
            }
            return embedding;
        }

        @Override
        public Batchifier getBatchifier() {
            return null; // We handle batching manually in processInput
        }
    }
}
