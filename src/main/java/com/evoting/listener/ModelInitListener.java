package com.evoting.listener;

import com.evoting.util.FaceEmbeddingUtil;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.io.InputStream;
import java.util.Properties;

/**
 * Application lifecycle listener that initializes the ArcFace ONNX model at startup
 * and cleans up resources at shutdown.
 */
@WebListener
public class ModelInitListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext ctx = sce.getServletContext();
        ctx.log("Initializing ArcFace face recognition model...");

        try {
            // Load face config from app.properties
            Properties props = new Properties();
            InputStream is = getClass().getClassLoader().getResourceAsStream("app.properties");
            if (is != null) {
                props.load(is);
                is.close();
            }

            String modelPath = props.getProperty("face.model.path", "/models/arcface_r100.onnx");

            FaceEmbeddingUtil.init(modelPath);
            ctx.log("ArcFace model initialized successfully from: " + modelPath);

            // Store config in ServletContext for servlet access
            ctx.setAttribute("face.similarity.threshold",
                    Double.parseDouble(props.getProperty("face.similarity.threshold", "0.60")));
            ctx.setAttribute("face.max.attempts",
                    Integer.parseInt(props.getProperty("face.max.attempts", "3")));
            ctx.setAttribute("face.liveness.enabled",
                    Boolean.parseBoolean(props.getProperty("face.liveness.enabled", "true")));
            ctx.setAttribute("face.liveness.frames",
                    Integer.parseInt(props.getProperty("face.liveness.frames", "3")));

        } catch (Exception e) {
            ctx.log("WARNING: Failed to initialize ArcFace model: " + e.getMessage()
                + ". Face capture/verify features will be unavailable until the model is loaded.", e);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        sce.getServletContext().log("Shutting down ArcFace model...");
        FaceEmbeddingUtil.close();
    }
}
