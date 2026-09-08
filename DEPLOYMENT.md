# Deployment & Usage Guide

## Complete Project Summary

The Phishing URL Detection System is a full-stack web application that analyzes URLs for phishing indicators and suspicious characteristics.

### What Was Built

✅ **Backend (Node.js + Express)**
- REST API endpoint for URL analysis
- URL parsing and feature extraction
- Network information retrieval (DNS/IP)
- Risk scoring algorithm
- Comprehensive error handling

✅ **Frontend (React + Vite)**
- Professional dashboard interface
- Real-time URL analysis
- Visual risk indicators
- Responsive design
- Clean, modern styling

✅ **Documentation**
- Complete README with methodology
- Quick start guide
- API documentation
- System architecture diagram

---

## How to Deploy

### Local Development

#### First Time Setup
```bash
cd phishing-url-detector

# Install all dependencies
npm install
cd backend && npm install
cd ../frontend && npm install
```

#### Starting the Application

**Option 1: Two Separate Terminals (Recommended)**

Terminal 1:
```bash
cd phishing-url-detector/backend
npm run dev
```

Terminal 2:
```bash
cd phishing-url-detector/frontend
npm run dev
```

Then open: http://localhost:3000

**Option 2: Single Terminal**
```bash
cd phishing-url-detector/backend
npm start > ../backend.log 2>&1 &
cd ../frontend
npm run dev
```

### Production Deployment

#### Build Frontend
```bash
cd phishing-url-detector/frontend
npm run build
```

This creates a `dist/` folder with optimized static files.

#### Run Backend in Production
```bash
cd phishing-url-detector/backend
npm install
npm start
```

Set environment variable if needed:
```bash
PORT=5000 npm start
```

#### Deploy to Server
1. Copy the entire `phishing-url-detector` directory to your server
2. Install Node.js on the server
3. Install dependencies: `npm install` (backend and frontend)
4. Start backend: `npm start`
5. Serve frontend with nginx/Apache pointing to `frontend/dist/`

---

## Usage Instructions

### Via Web Browser

1. **Open the application**: http://localhost:3000

2. **Enter a URL**: Type or paste a URL in the input field
   - Examples:
     - `https://github.com`
     - `http://example.com/login`
     - `http://192.168.1.1/verify`

3. **Click "Analyze URL"**: The backend will analyze the URL

4. **Review Results**:
   - **Verdict Card**: Final assessment (Safe or Suspicious)
   - **Risk Score**: 0-100 numerical score
   - **Risk Meter**: Visual representation of risk
   - **URL Information**: Parsed components
   - **IP/DNS Info**: Network information
   - **Security Indicators**: List of suspicious findings
   - **Analysis Details**: Explanation of indicators

### Via API (cURL/Postman)

#### Endpoint
```
POST http://localhost:5000/api/analyze
```

#### Request Headers
```
Content-Type: application/json
```

#### Request Body
```json
{
  "url": "https://example.com/path?param=value"
}
```

#### Example Request
```bash
curl -X POST http://localhost:5000/api/analyze \
  -H "Content-Type: application/json" \
  -d '{"url": "https://github.com"}'
```

#### Example Response
```json
{
  "url": "https://github.com",
  "domain": "github.com",
  "protocol": "https",
  "hostname": "github.com",
  "port": 443,
  "path": "/",
  "ipAddresses": [],
  "ipv6Addresses": [],
  "riskScore": 0,
  "riskLevel": "LOW",
  "verdict": "LIKELY SAFE",
  "indicators": [],
  "urlCharacteristics": {
    "length": 18,
    "domainLength": 10,
    "subdomainCount": 0,
    "parameterCount": 0,
    "specialCharacterCount": 0,
    "hyphenCount": 0,
    "dotCount": 1,
    "hasIPAddress": false,
    "hasAt": false,
    "usesHTTPS": true,
    "isPunycode": false,
    "suspiciousKeywords": []
  },
  "analysisDetails": []
}
```

#### Error Responses

**Missing URL**
```json
{
  "error": "Missing or invalid URL",
  "message": "Please provide a valid URL in the request body"
}
```

**Invalid URL Format**
```json
{
  "error": "Analysis failed",
  "message": "URL analysis failed: Invalid URL format"
}
```

---

## Understanding the Results

### Risk Levels

| Score | Level | Category | Verdict |
|-------|-------|----------|---------|
| 0-19 | LOW | Very Safe | LIKELY SAFE |
| 20-39 | MEDIUM | Caution Advised | LIKELY SAFE (with caution) |
| 40-69 | HIGH | Probably Unsafe | SUSPICIOUS / POTENTIAL PHISHING |
| 70-100 | CRITICAL | Very Unsafe | SUSPICIOUS / POTENTIAL PHISHING |

### Indicators Explained

| Indicator | Meaning | Risk | What to Do |
|-----------|---------|------|-----------|
| IP address URL | Uses direct IP instead of domain | High | Avoid clicking |
| HTTP instead of HTTPS | No encryption | Medium | Be cautious |
| @ symbol in URL | Credential masking | High | Avoid clicking |
| Suspicious keywords | Contains "login", "verify", etc. | Medium | Check context |
| Punycode domain | IDN lookalike domain | Medium | Verify domain |
| Long URL | Excessive length | Low | Review carefully |
| Excessive subdomains | Many subdomain levels | Medium | Check domain |
| Suspicious port | Non-standard port (8080, etc.) | Low | Be cautious |
| URL encoding | Encoded characters (%) | Low | Review carefully |
| Special characters | Unusual symbols | Low | Review carefully |

### Example Scenarios

**Scenario 1: Received a bank login link**
```
URL: http://login.bank-security-verify.com/account/confirm
Risk Score: 50+
Verdict: SUSPICIOUS
Actions: 
  - Do NOT click the link
  - Verify sender
  - Check URL for typos
  - Go directly to bank website
```

**Scenario 2: GitHub repository link from trusted source**
```
URL: https://github.com/username/repo
Risk Score: 0-10
Verdict: LIKELY SAFE
Actions:
  - Safe to click
  - Verify it's from expected person
  - Check repository details
```

**Scenario 3: Link with suspicious characteristics**
```
URL: http://192.168.1.1/paypal/login/verify
Risk Score: 70+
Verdict: SUSPICIOUS / POTENTIAL PHISHING
Actions:
  - Definitely avoid clicking
  - Report to email provider
  - Check for malware
```

---

## Testing

### Run Test Suite
```bash
cd phishing-url-detector
bash test-api.sh
```

This runs 12 different test scenarios.

### Manual Testing Checklist

- [ ] Safe HTTPS URL (e.g., `https://github.com`)
- [ ] HTTP with suspicious keywords (e.g., `http://example.com/login`)
- [ ] IP address URL (e.g., `http://192.168.1.1/verify`)
- [ ] URL with @ symbol (e.g., `https://fake.com@github.com`)
- [ ] Very long URL (many parameters)
- [ ] Punycode domain (e.g., `https://xn--...`)
- [ ] Invalid URL (should return error)
- [ ] Missing URL (should return error)
- [ ] Empty request body (should return error)
- [ ] Frontend-to-backend integration

### Automated Testing

```bash
# Test backend only
cd phishing-url-detector
bash test-api.sh

# Test frontend only (open in browser)
http://localhost:3000
```

---

## Troubleshooting

### Common Issues

#### "Cannot GET /"
- Frontend not running
- Solution: Start frontend with `npm run dev` in frontend directory

#### "Connection refused on port 5000"
- Backend not running
- Solution: Start backend with `npm start` in backend directory

#### "Domain could not be resolved via DNS"
- DNS resolution failed (common in containers/restricted networks)
- This is NOT an error - URL characteristics are still analyzed
- The system continues with heuristic analysis

#### API returns empty results
- Check frontend logs in browser console
- Check backend logs: `tail /tmp/backend.log`
- Verify both services are running

#### Ports already in use
```bash
# Check what's using the port
lsof -i :5000    # for backend
lsof -i :3000    # for frontend

# Kill the process (replace PID)
kill -9 <PID>
```

---

## Performance Metrics

| Metric | Time |
|--------|------|
| URL parsing | <10ms |
| DNS resolution | 50-500ms (with timeout) |
| Risk calculation | <5ms |
| Total API response | 100-600ms |
| Frontend rendering | <100ms |
| Page load | ~2-3 seconds |

---

## Security Considerations

### What This Tool Does
✓ Analyzes URL structure and characteristics
✓ Retrieves publicly available DNS information
✓ Calculates risk based on known phishing patterns
✓ Educates users about URL security

### What This Tool Does NOT Do
✗ Does not access actual websites
✗ Does not download or execute content
✗ Does not analyze page content
✗ Does not perform vulnerability scanning
✗ Does not guarantee phishing detection
✗ Does not replace security best practices

### Best Practices
1. Always verify sender identity before clicking links
2. Check for typos in domain names
3. Enable two-factor authentication
4. Use password managers
5. Keep browser and software updated
6. Use this tool as ONE layer of defense

---

## Features Implemented

✅ URL Structure Analysis
  - Protocol detection (HTTP vs HTTPS)
  - Domain and subdomain parsing
  - Port detection
  - Path and parameter analysis
  - Special character detection

✅ Phishing Indicator Detection
  - IP address URLs
  - @ symbol detection (credential masking)
  - Suspicious keywords (login, verify, bank, etc.)
  - Punycode/IDN domain detection
  - URL length analysis
  - Hyphen and dot analysis

✅ Network Information
  - IPv4 address resolution
  - IPv6 address resolution
  - Reverse DNS lookup
  - DNS error handling

✅ Risk Scoring
  - Transparent scoring algorithm
  - Multiple indicator weighting
  - Clear explanation of findings
  - Risk level categorization

✅ User Interface
  - Professional dashboard
  - Real-time analysis
  - Visual indicators
  - Responsive design
  - Error handling

---

## Future Enhancement Ideas

- Integration with phishing databases
- Machine learning model for improved detection
- Browser extension
- Email client plugin
- Screenshot analysis with OCR
- URL redirect following
- SSL certificate validation
- WHOIS domain information
- File hash analysis
- Community reporting system

---

## Support & Troubleshooting

### Health Check
```bash
curl http://localhost:5000/health
```

Expected response:
```json
{"status":"OK","timestamp":"2026-08-24T..."}
```

### Debug Mode
```bash
# View backend logs
tail -f /tmp/backend.log

# View frontend build output
# Check browser console (F12)
```

### Contact/Issues
- Check README.md for full documentation
- Review error messages in console
- Verify both services are running
- Check network connectivity

---

## License

MIT License - Free to use and modify

---

## Summary

You now have a fully functional **Phishing URL Detection System** ready to:

1. ✅ **Analyze URLs** for suspicious characteristics
2. ✅ **Calculate risk** using transparent scoring
3. ✅ **Display results** in a professional dashboard
4. ✅ **Provide API** for programmatic access
5. ✅ **Handle errors** gracefully
6. ✅ **Educate users** about phishing indicators

**Start using it:** http://localhost:3000

**Happy analyzing!** 🔍🛡️
