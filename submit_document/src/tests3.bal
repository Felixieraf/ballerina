import ballerinax/aws.s3;
import ballerina/config;
import ballerina/http;
import ballerina/io;

 // Create the ClientConfiguration that can be used to connect with the Amazon S3 service..
s3:ClientConfiguration amazonS3Config = {
    accessKeyId: config:getAsString("ACCESS_KEY_ID"),
    secretAccessKey: config:getAsString("SECRET_ACCESS_KEY"),
    region: config:getAsString("REGION")
};

s3:AmazonS3Client|s3:ConnectorError amazonS3Client = new(amazonS3Config);

public function main() {
    // Create the AmazonS3 client with amazonS3Config. 
    s3:AmazonS3Client|s3:ConnectorError amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is s3:AmazonS3Client) {
        string bucketName = "sample-amazon-bucket";
        s3:CannedACL cannedACL = s3:ACL_PRIVATE;
        // Invoke createBucket remote function using base/parent Amazon S3 client.
        s3:ConnectorError? createBucketResponse = amazonS3Client->createBucket(bucketName, cannedACL);
        if (createBucketResponse is s3:ConnectorError) {
            // If unsuccessful, print the error returned.
            io:println("Error: ", createBucketResponse.reason());
        } else {
            // If successful, print the status of the operation.
            io:println("Bucket Creation Status: Success");
        }
    }
}