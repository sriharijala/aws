package com.amazonaws.samples;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLDecoder;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.imageio.ImageIO;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.S3Event;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.event.S3EventNotification.S3EventNotificationRecord;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.S3Object;

public class ImageResize implements RequestHandler<S3Event, String> {
	
	private static final float MAX_WIDTH = 100;
	private static final float MAX_HEIGHT = 100;
	private final String JPG_TYPE = (String) "jpg";
	private final String JPG_MIME = (String) "image/jpeg";
	private final String PNG_TYPE = (String) "png";
	private final String PNG_MIME = (String) "image/png";

	public String handleRequest(S3Event s3event, Context context) {
		
		LambdaLogger logger = context.getLogger();
		
		try {
			S3EventNotificationRecord record = s3event.getRecords().get(0);

			String srcBucket = record.getS3().getBucket().getName();
			// Object key may have spaces or unicode non-ASCII characters.
			String srcKey = record.getS3().getObject().getKey().replace('+', ' ');
			srcKey = URLDecoder.decode(srcKey, "UTF-8");

			String dstBucket = srcBucket + "resized";
			String dstKey = "resized-" + srcKey;

			logger.log("Source bucket " + srcBucket + " , destination bucket : " + dstBucket + "\n");
			
			// Sanity check: validate that source and destination are different
			// buckets.
			if (srcBucket.equals(dstBucket)) {
				logger.log("Destination bucket must not match source bucket." + dstBucket + "\n");
				return "";
			}

		// Infer the image type.
			Matcher matcher = Pattern.compile(".*\\.([^\\.]*)").matcher(srcKey);
			if (!matcher.matches()) {
				logger.log("Unable to infer image type for key " + srcKey  + "\n");
				return "";
			}
			
			String imageType = matcher.group(1);
			
			logger.log("imageType : " + imageType + "\n");
			
			if (!(JPG_TYPE.equalsIgnoreCase(imageType)) && !(PNG_TYPE.equalsIgnoreCase(imageType))) {
				logger.log("Skipping non-image " + srcKey  + "\n");
				return "";
			}

			// Download the image from S3 into a stream
			AmazonS3 s3Client = new AmazonS3Client();
			
			logger.log("Access object " + srcKey + "\n");
			S3Object s3Object = s3Client.getObject(new GetObjectRequest(srcBucket, srcKey));
			InputStream objectData = s3Object.getObjectContent();

			// Read the source image
			BufferedImage srcImage = ImageIO.read(objectData);
			int srcHeight = srcImage.getHeight();
			int srcWidth = srcImage.getWidth();
			// Infer the scaling factor to avoid stretching the image
			// unnaturally
			float scalingFactor = Math.min(MAX_WIDTH / srcWidth, MAX_HEIGHT / srcHeight);
			int width = (int) (scalingFactor * srcWidth);
			int height = (int) (scalingFactor * srcHeight);

			BufferedImage resizedImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
			Graphics2D g = resizedImage.createGraphics();
			// Fill with white before applying semi-transparent (alpha) images
			g.setPaint(Color.white);
			g.fillRect(0, 0, width, height);
			// Simple bilinear resize
			// If you want higher quality algorithms, check this link:
			// https://today.java.net/pub/a/today/2007/04/03/perils-of-image-getscaledinstance.html
			g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
			g.drawImage(srcImage, 0, 0, width, height, null);
			g.dispose();

			// Re-encode image to target format
			ByteArrayOutputStream os = new ByteArrayOutputStream();
			ImageIO.write(resizedImage, imageType, os);
			InputStream is = new ByteArrayInputStream(os.toByteArray());
			// Set Content-Length and Content-Type
			ObjectMetadata meta = new ObjectMetadata();
			meta.setContentLength(os.size());
			if (JPG_TYPE.equals(imageType)) {
				meta.setContentType(JPG_MIME);
			}
			if (PNG_TYPE.equals(imageType)) {
				meta.setContentType(PNG_MIME);
			}

			// Uploading to S3 destination bucket
			logger.log("Writing to: " + dstBucket + "/" + dstKey);
			s3Client.putObject(dstBucket, dstKey, is, meta);
			logger.log("Successfully resized " + srcBucket + "/" + srcKey + " and uploaded to " + dstBucket
					+ "/" + dstKey);
			return "Ok";
			
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

}
