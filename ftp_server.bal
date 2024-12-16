// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/file;
import ballerina/ftp;
import ballerina/io;
import ballerina/log;

string ftpHost = protocol.SFTP.host ?: "127.0.0.1";
int ftpPort = protocol.SFTP.port ?: 23;
string username = protocol.SFTP.username ?: "";
string password = protocol.SFTP.password ?: "";

// Creates the listener with the connection parameters and the protocol-related
// configuration. The listener listens to the files
// with the given file name pattern located in the specified path.
listener ftp:Listener fileListener = new ({
    host: ftpHost,
    auth: {
        credentials: {
            username: username,
            password: password
        }
    },
    port: ftpPort,
    path: protocol.SFTP.ftpDirectory,
    fileNamePattern: "(.*).txt",
    pollingInterval: 1
});


// One or many services can listen to the SFTP listener for the
// periodically-polled file related events.
service on fileListener {

    // When a file event is successfully received, the `onFileChange` method is called.
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {

        // `addedFiles` contains the paths of the newly-added files/directories after the last polling was called.
        foreach ftp:FileInfo addedFile in event.addedFiles {

            log:printDebug(string `File received: ${addedFile.name}`);
            // Get the newly added file from the SFTP server as a `byte[]` stream.
            stream<byte[] & readonly, io:Error?> fileStream = check caller->get(addedFile.pathDecoded);
            
            // copy to local file system
            check io:fileWriteBlocksFromStream(string `./temp/${addedFile.name}`, fileStream);
            check fileStream.close();

            if protocol.SFTP.deleteFromFTPOnRead {
                // Delete the file from the SFTP server after reading.
                check caller->delete(addedFile.pathDecoded);
            }
            // performs a read operation to read the lines as an array.
            string readLines = check io:fileReadString(protocol.SFTP.inputFileStorePath + string `${addedFile.name}`);
            // Write the content to a file.
            if (!protocol.SFTP.saveReadFileToLocal) {
                // Delete the temporary file after processing.
                check file:remove(protocol.SFTP.inputFileStorePath + string `${addedFile.name}`);
            }
            
            logMessage("MT->MX", readLines.toBalString());
            xml output = transformMtToMx(readLines);
            logMessage("MT->MX", output.toBalString(), true);
            string outputFileName = string `/result_${addedFile.name}`;
            check io:fileWriteXml(protocol.SFTP.outputFileStorePath + outputFileName, output);
            // Send the output file to the FTP server.
            stream<io:Block, io:Error?> outputFileStream = 
                check io:fileReadBlocksAsStream(protocol.SFTP.outputFileStorePath + outputFileName, 1024);
            check fileClient->put("/outputs/" + outputFileName, outputFileStream);
        }
    }
}

