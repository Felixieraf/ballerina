import ballerina/email;
import ballerina/io;

public function main() {

    email:SmtpClient smtpClient = new ("smtp.email.com", "sender@email.com"
        , "pass123");

    email:Email email = {

        to: ["receiver1@email.com", "receiver2@email.com"],
        cc: ["receiver3@email.com", "receiver4@email.com"],
        bcc: ["receiver5@email.com"],

        subject: "Sample Email",

        body: "This is a sample email.",

        'from: "author@email.com",

        sender: "sender@email.com",

        replyTo: ["replyTo1@email.com", "replyTo2@email.com"]
    };

    email:Error? response = smtpClient->send(email);
    if (response is email:Error) {
        io:println("Error while sending the email: "
            + <string> response.detail()["message"]);
    }

}