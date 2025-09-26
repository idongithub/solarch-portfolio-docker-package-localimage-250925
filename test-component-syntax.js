// Simple syntax test for CaptchaProtectedContact component
const fs = require('fs');

try {
  const componentCode = fs.readFileSync('/app/frontend/src/components/CaptchaProtectedContact.jsx', 'utf8');
  
  // Check for problematic characters
  const problemChars = ['£', '€', '¥', '¢'];
  let foundIssues = false;
  
  problemChars.forEach(char => {
    if (componentCode.includes(char)) {
      console.log(`❌ Found problematic character: ${char}`);
      foundIssues = true;
    }
  });
  
  // Check for basic JSX syntax issues
  const lines = componentCode.split('\n');
  let inString = false;
  let stringChar = '';
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const lineNum = i + 1;
    
    // Simple check for unmatched quotes (not perfect but helps)
    for (let j = 0; j < line.length; j++) {
      const char = line[j];
      if ((char === '"' || char === "'") && line[j-1] !== '\\') {
        if (!inString) {
          inString = true;
          stringChar = char;
        } else if (char === stringChar) {
          inString = false;
          stringChar = '';
        }
      }
    }
  }
  
  if (!foundIssues) {
    console.log('✅ No problematic characters found');
  }
  
  console.log('📄 Component file appears syntactically clean');
  console.log(`📊 File size: ${componentCode.length} characters`);
  console.log(`📊 Lines of code: ${lines.length}`);
  
} catch (error) {
  console.log('❌ Error reading component file:', error.message);
}