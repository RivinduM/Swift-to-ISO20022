import React, { useState } from "react";

function App() {
  const [inputValue, setInputValue] = useState("");
  const [output, setOutput] = useState("");
  const [isMTtoMX, setIsMTtoMX] = useState(true); // State to track the mode
  const [selectedMTType, setSelectedMTType] = useState(""); // State to store selected MT message type

  // Available MT Message Types for MX to MT transformation
  const mtMessageTypes = [
    { value: "MT210", label: "MT210" },
    { value: "MT101", label: "MT101" },
    // Add more MT types as needed
  ];


  // Handle Transformation
  const handleTransform = async () => {
    let url = isMTtoMX
      ? "http://localhost:9090/mt-mx/transform"
      : "http://localhost:9090/mx-mt/transform";

    // Add the selected MT message type as a query parameter for MX to MT transformation
    if (!isMTtoMX && selectedMTType) {
      url += `?targetType=${selectedMTType}`;
    }

    const headers = {
      "Content-Type": isMTtoMX ? "text/plain" : "application/xml", // Change header based on mode
    };
    const body = isMTtoMX ? inputValue : inputValue; // Send input as is (already in the correct format)

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
      <textarea
        placeholder={isMTtoMX ? "Enter MT message here..." : "Enter MX message here..."} // Update placeholder dynamically
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
            setIsMTtoMX((prev) => !prev); // Toggle between MT-MX and MX-MT modes
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

        {isMTtoMX ? null : (
          <div style={{ marginTop: "10px" }}>
            <label htmlFor="mtType" style={{ display: "block" }}>
              Select Target MT Message Type:
            </label>
            <select
              id="mtType"
              value={selectedMTType}
              onChange={(e) => setSelectedMTType(e.target.value)}
              style={{
                padding: "10px",
                fontSize: "16px",
                width: "100%",
                borderRadius: "5px",
              }}
            >
              <option value="">--Select MT Type--</option>
              {mtMessageTypes.map((type) => (
                <option key={type.value} value={type.value}>
                  {type.label}
                </option>
              ))}
            </select>
          </div>
        )}

        {/* <button
          onClick={handleTransform} // Submit button calls the backend
          style={{
            padding: "10px",
            backgroundColor: "#007BFF",
            color: "white",
            border: "none",
            borderRadius: "5px",
            cursor: "pointer",
            marginTop: "10px", 
            paddingTop: "10px", 
          }}
        >
          Submit
        </button> */}
      </div>

      <div style={{ marginTop: "20px" }}>
        <button
          onClick={handleTransform} // Submit button calls the backend
          style={{
            padding: "10px",
            backgroundColor: "#007BFF",
            color: "white",
            border: "none",
            borderRadius: "5px",
            cursor: "pointer",
            marginTop: "10px", // Space above submit button
            paddingTop: "10px", // Add top padding for more spacing
          }}
        >
          Submit
        </button>

        <button
          onClick={handleClearResponse} // Clear response button
          style={{
            padding: "10px",
            backgroundColor: "#f44336",
            color: "white",
            border: "none",
            borderRadius: "5px",
            cursor: "pointer",
            marginLeft: "10px",
            marginTop: "20px", // Space above clear button
          }}
        >
          Clear Response
        </button>
      </div>

      <textarea
        readOnly
        value={output}
        rows={15}
        style={{
          width: "100%",
          height: "300px",
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
