import React, { useState } from "react";
import { Tabs, Tab, Box, TextareaAutosize, Select, MenuItem, FormControl, InputLabel, Button } from "@mui/material";

function App() {
  const [inputValue, setInputValue] = useState("");
  const [output, setOutput] = useState("");
  const [selectedTab, setSelectedTab] = useState(0); // 0 for API, 1 for SFTP, 2 for MQ
  const [isMTtoMX, setIsMTtoMX] = useState(true); // State to track the mode for API
  const [selectedMTType, setSelectedMTType] = useState(""); // State to store selected MT message type
  const [inputFile, setInputFile] = useState(null); // State to hold the file
  const [mqMessage, setMqMessage] = useState(""); // State to store MQ message

  // Available MT Message Types for MX to MT transformation
  const mtMessageTypes = [
    { value: "MT210", label: "MT210" },
    { value: "MT101", label: "MT101" },
    // Add more MT types as needed
  ];

  // Handle API Transformation for MT to MX or MX to MT
  const handleAPICall = async () => {
    let url = isMTtoMX
      ? "http://localhost:9090/mt-mx/transform"
      : "http://localhost:9090/mx-mt/transform";

    if (!isMTtoMX && selectedMTType) {
      url += `?targetType=${selectedMTType}`;
    }

    const headers = {
      "Content-Type": isMTtoMX ? "text/plain" : "application/xml",
    };
    const body = isMTtoMX ? inputValue : inputValue;

    try {
      const response = await fetch(url, {
        method: "POST",
        headers: headers,
        body: body,
      });

      if (response.ok) {
        const data = await response.text();
        if (isMTtoMX) {
          setOutput(`Transformed MX Message (XML):\n\n${formatXML(data)}`);
        } else {
          setOutput(`Transformed MT Message (Plain Text):\n\n${data}`);
        }
      } else {
        throw new Error(`Unexpected response: ${response.status} ${response.statusText}`);
      }
    } catch (error) {
      setOutput(`Error:\n${error.message}`);
    }
  };

// Handle file selection
const handleFileChange = (event) => {
  const file = event.target.files[0];
  setInputFile(file); // Store the selected file in the state
};

// Handle file upload
const handleFileUpload = async () => {
  if (!inputFile) {
    setOutput("Please select a file to upload.");
    return;
  }

  const fileName = inputFile.name; // Get the file name
  const url = `http://localhost:9091/file/sendToFtp?fileName=${fileName}`; // URL with query param

  // const formData = new FormData();
  // formData.append("file", inputFile); // Append the file to the FormData object

  try {
    const response = await fetch(url, {
      method: "GET",
      // body: formData, // Send the file as form data
    });

    if (response.ok) {
      setOutput(`File uploaded successfully. Output file uploaded to outpusts/result_` + fileName);
    } else {
      throw new Error(`Failed to upload file: ${response.status} ${response.statusText}`);
    }
  } catch (error) {
    setOutput(`Error: ${error.message}`);
  }
};

  // Handle MQ logic (message sending)
  // const handleMQSend = async () => {
  //   if (!mqMessage) {
  //     setOutput("Please enter a message to send to MQ.");
  //     return;
  //   }

  //   const url = "http://localhost:9092/mq/sendToMQ"; // Backend endpoint
  //   const headers = {
  //     "Content-Type": "application/json", // Set content type as JSON
  //   };
  //   const body = JSON.stringify({ payload: mqMessage }); // Send message as JSON payload

  //   try {
  //     const response = await fetch(url, {
  //       method: "POST",
  //       headers: headers,
  //       body: body, // Send the MQ message
  //     });

  //     if (response.ok) {
  //       const data = await response.text();
  //       setOutput(`MQ message sent successfully: ${data}`);
  //     } else {
  //       throw new Error(`Failed to send MQ message: ${response.status} ${response.statusText}`);
  //     }
  //   } catch (error) {
  //     setOutput(`Error: ${error.message}`);
  //   }
  // };

  // Clear Output
  const handleClearResponse = () => {
    setOutput(""); // Clears the output field
  };

  const formatXML = (xml) => {
    const PADDING = "  ";
    const reg = /(>)(<)(\/*)/g;
    let pad = 0;
    return xml
      .replace(reg, "$1\n$2$3")
      .split("\n")
      .map((node) => {
        let indent = "";
        if (node.match(/.+<\/\w[^>]*>$/)) {
          indent = "";
        } else if (node.match(/^<\/\w/)) {
          if (pad !== 0) {
            pad -= 1;
          }
        } else if (node.match(/^<\w([^>]*[^/])?>.*$/)) {
          indent = PADDING.repeat(pad);
          pad += 1;
        } else {
          indent = PADDING.repeat(pad);
        }
        return indent + node;
      })
      .join("\n");
  };

  // Handle MQ Message input change
  const handleMqMessageChange = (event) => {
    setMqMessage(event.target.value);
  };

  // Handle sending MQ message
  const handleSendMqMessage = async () => {
    if (!mqMessage) {
      setOutput("Please enter a message to send to MQ.");
      return;
    }

    const url = "http://localhost:9092/mq/sendToMQ"; // Backend endpoint
    const headers = {
      "Content-Type": "text/plain", // Set content type as JSON
    };
    const body = mqMessage; // Send message as JSON payload
    // const cleanedMessage = body.replace(/\\n/g, "\n").replace(/\\t/g, "\t");

    try {
      const response = await fetch(url, {
        method: "POST",
        headers: headers,
        body: body, // Send the MQ message
      });

      if (response.ok) {
        const data = await response.text();
        setOutput(`MQ message sent successfully. Output file uploaded to /outputs/result_mq.xml`);
      } else {
        throw new Error(`Failed to send MQ message: ${response.status} ${response.statusText}`);
      }
    } catch (error) {
      setOutput(`Error: ${error.message}`);
    }
  };

  return (
    <div style={{ padding: "20px" }}>
      <div style={{ display: "flex", alignItems: "center", marginBottom: "20px" }}>
        <img
          src="https://wso2.cachefly.net/wso2/sites/all/image_resources/wso2-branding-logos/wso2-logo.png" // Replace with your logo URL or path
          alt="WSO2 Logo"
          style={{ height: "50px", marginRight: "10px" }}
        />
        <h1>WSO2 Swift MT MX Translation Playground</h1>
      </div>

      {/* MUI Tabs for switching between API, SFTP, and MQ */}
      <Box sx={{ width: "100%", marginBottom: "20px" }}>
        <Tabs value={selectedTab} onChange={(e, newValue) => {setSelectedTab(newValue); setOutput("")}} aria-label="method selection">
          <Tab label="API" />
          <Tab label="SFTP" />
          <Tab label="MQ" />
        </Tabs>
      </Box>

      {/* Conditional Rendering based on selected Tab */}
      {selectedTab === 0 && (
        <>
          {/* API Transformation Logic */}
          <div style={{ marginBottom: "10px" }}>
            <textarea
              placeholder={isMTtoMX ? "Enter MT message here..." : "Enter MX message here..."}
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              rows={15}
              style={{
                width: "100%",
                height: "200px",
                padding: "10px",
                marginBottom: "10px",
                fontSize: "16px",
                border: "1px solid #ccc",
                borderRadius: "5px",
              }}
            />
            <div style={{ margin: "10px 0" }}>
              <button
                onClick={() => {
                  setIsMTtoMX((prev) => !prev);
                }}
                style={{
                  padding: "10px",
                  marginRight: "10px",
                  backgroundColor: "#4CAF50",
                  color: "white",
                  border: "none",
                  borderRadius: "5px",
                  cursor: "pointer",
                }}
              >
                {isMTtoMX ? "Transform MT to MX" : "Transform MX to MT"}
              </button>
            </div>

            {/* MT Message Type Selector for MX to MT */}
            {!isMTtoMX && (
              <div style={{ marginTop: "10px" }}>
                <FormControl fullWidth>
                  <InputLabel id="mtType">Select MT Message Type</InputLabel>
                  <Select
                    labelId="mtType"
                    value={selectedMTType}
                    onChange={(e) => setSelectedMTType(e.target.value)}
                    label="Select MT Message Type"
                  >
                    <MenuItem value="">--Select MT Type--</MenuItem>
                    {mtMessageTypes.map((type) => (
                      <MenuItem key={type.value} value={type.value}>
                        {type.label}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </div>
            )}
          </div>
        </>
      )}

      {/* SFTP Tab (File Upload Logic Placeholder) */}
      {selectedTab === 1 && (
        <div style={{ marginBottom: "10px" }}>
          <input type="file" onChange={handleFileChange} />
          
          <Button
            onClick={handleFileUpload}
            style={{
              padding: "10px",
              backgroundColor: "#007BFF",
              color: "white",
              border: "none",
              borderRadius: "5px",
              cursor: "pointer",
              marginTop: "10px",
            }}
          >
            Upload File
          </Button>
        </div>
      )}

      {/* MQ Tab (Message Send Logic Placeholder) */}
      {selectedTab === 2 && (
        <div style={{ marginBottom: "10px" }}>
          <textarea
            placeholder="Enter MQ message here..."
            value={mqMessage}
            onChange={handleMqMessageChange}
            rows={15}
            style={{
              width: "100%",
              height: "200px",
              padding: "10px",
              marginBottom: "10px",
              fontSize: "16px",
              border: "1px solid #ccc",
              borderRadius: "5px",
            }}
          />
          <Button
            onClick={handleSendMqMessage}
            style={{
              padding: "10px",
              backgroundColor: "#007BFF",
              color: "white",
              border: "none",
              borderRadius: "5px",
              cursor: "pointer",
              marginTop: "10px",
            }}
          >
            Send MQ Message
          </Button>
        </div>
      )}

      {/* Submit and Clear Buttons */}
      <div style={{ marginTop: "20px" }}>
      {selectedTab === 0 && ( // Only render Submit button for API tab
        <>
        <Button
          onClick={selectedTab === 0 ? handleAPICall : selectedTab === 1 ? handleFileUpload : handleSendMqMessage}
          style={{
            padding: "10px",
            backgroundColor: "#007BFF",
            color: "white",
            border: "none",
            borderRadius: "5px",
            cursor: "pointer",
            marginTop: "10px",
          }}
        >
          Submit
        </Button>

        <Button
          onClick={handleClearResponse}
          style={{
            padding: "10px",
            backgroundColor: "rgb(151 138 137)",
            color: "white",
            border: "none",
            borderRadius: "5px",
            cursor: "pointer",
            marginLeft: "10px",
            marginTop: "10px",
          }}
        >
          Clear Response
        </Button>
        </>
        )}
      </div>

      <TextareaAutosize
        readOnly
        value={output}
        minRows={6}
        style={{
          width: "100%",
          height: "auto",
          padding: "10px",
          marginTop: "20px",
          fontSize: "16px",
          border: "1px solid #ccc",
          borderRadius: "5px",
          backgroundColor: "#f9f9f9",
        }}
      />
    </div>
  );
}

export default App;
