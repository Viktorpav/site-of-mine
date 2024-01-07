# zip it in order to work with redirect function

import boto3
import os
import subprocess

s3 = boto3.client('s3')

def lambda_handler(event, context):
    # Loop over every record
    for record in event['Records']:
        # Get the object from the record and show its content type
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        download_path = '/tmp/{}'.format(os.path.basename(key))
        upload_folder = '/tmp/hls-{}'.format(os.path.splitext(os.path.basename(key))[0])
        
        # Create the output directory if it doesn't exist
        os.makedirs(upload_folder, exist_ok=True)

        # Download the video file from S3 to the Lambda function's temp storage
        s3.download_file(bucket, key, download_path)
        
        # Use FFmpeg to convert the video to HLS format
        command = ['/opt/bin/ffmpeg', '-i', download_path, '-profile:v', 'baseline', '-level', '3.0', '-pix_fmt', 'yuv420p', '-start_number', '0', '-hls_time', '10', '-hls_list_size', '0', '-f', 'hls', '{}/index.m3u8'.format(upload_folder)]
        
        try:
            output = subprocess.check_output(command, stderr=subprocess.STDOUT)
            print(f"FFmpeg output: {output}")
        except subprocess.CalledProcessError as e:
            print(f"FFmpeg failed with return code {e.returncode} and output:\n{e.output}")
            raise e

        # Upload the converted video back to S3
        converted_key_folder = 'converted/{}'.format(os.path.splitext(os.path.basename(key))[0]) if 'converted' not in key else key
        for root, dirs, files in os.walk(upload_folder):
            for file in files:
                s3.upload_file(os.path.join(root, file), bucket, '{}/{}'.format(converted_key_folder, file))