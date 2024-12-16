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

# Protocol record that define the supported protocol configurations.
#
# + API - Rest API configuration
# + SFTP - SFTP configuration
# + MQ - MQ configuration
type Protocol record {|
    ProtocolConfig API;
    SFTPProtocolConfig SFTP;
    MQProtocolConfig MQ;
|};

# Define protocol specific configurations.
#
# + enabled - boolean field to enable or disable the protocol 
# + host - hostname
# + port - port number
type ProtocolConfig record {
    boolean enabled;
    string host?;
    int port?;
};

# SFTP protocol specific configurations.
#
# + username - username  
# + password - password  
# + ftpDirectory - ftp directory
# + deleteFromFTPOnRead - boolean field to delete the file from FTP after reading  
# + saveReadFileToLocal - boolean field to save the read file to local  
# + inputFileStorePath - file path to store the input files  
# + outputFileStorePath - file path to store the output files
type SFTPProtocolConfig record {
    *ProtocolConfig;
    string username?;
    string password?;
    string ftpDirectory = "/";
    boolean deleteFromFTPOnRead = true;
    boolean saveReadFileToLocal = true;
    string inputFileStorePath = "./temp";
    string outputFileStorePath = "./output";
};

# MQ protocol specific configurations.
# 
# + queueName - queue name
# + outputFileStorePath - file path to store the output files
type MQProtocolConfig record {
    *ProtocolConfig;
    string queueName;
    string outputFileStorePath = "./output";
};

# Monitoring record that define the monitoring configurations.
# 
# + logging - logging configurations
type Monitoring record {|
   Logging logging;
|};

# Logging record that define the logging configurations.
#
# + enabled - boolean field to enable or disable the logging  
# + filePath - file path to store the logs
type Logging record {|
    boolean enabled;
    string filePath;
|};
