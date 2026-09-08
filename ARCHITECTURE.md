# Architecture & Implementation Details

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER BROWSER                              │
│                  (React + Vite Frontend)                         │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  1. URL Input Field                                     │   │
│  │  2. Analysis Button                                     │   │
│  │  3. Results Display Components                          │   │
│  │  4. Error & Loading States                              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            ↓ (HTTPS)                             │
│                     Fetch POST /api/analyze                      │
│                            ↓                                     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND SERVER                                │
│              (Express.js + Node.js on Port 5000)                │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Express Server (src/index.js)                           │  │
│  │  • CORS middleware                                       │  │
│  │  • JSON parser                                           │  │
│  │  • Error handler                                         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  POST /api/analyze Handler                              │  │
│  │  • Validate request                                      │  │
│  │  • Extract URL                                           │  │
│  │  • Call analyzer module                                  │  │
│  │  • Return JSON response                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Analyzer Module (src/analyzer.js)                       │  │
│  │  • Orchestrates all analysis steps                       │  │
│  │  • Combines results                                      │  │
│  │  • Returns structured response                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│          ↓                      ↓                    ↓           │
│  ┌────────────────┐   ┌────────────────┐   ┌────────────────┐  │
│  │ URL Parser     │   │ Network Info   │   │ Risk Scorer    │  │
│  │                │   │                │   │                │  │
│  │ Extracts:      │   │ Retrieves:     │   │ Calculates:    │  │
│  │ • Protocol     │   │ • IPv4 Addrs   │   │ • Risk Score   │  │
│  │ • Domain       │   │ • IPv6 Addrs   │   │ • Risk Level   │  │
│  │ • Hostname     │   │ • Reverse DNS  │   │ • Indicators   │  │
│  │ • Port         │   │ • DNS errors   │   │ • Verdict      │  │
│  │ • Path         │   │ • Timeouts     │   │ • Details      │  │
│  │ • Parameters   │   └────────────────┘   └────────────────┘  │
│  │ • Keywords     │                                             │
│  │ • IP detection │                                             │
│  │ • Punycode     │                                             │
│  │ • @ detection  │                                             │
│  └────────────────┘                                             │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  System Integration                                      │  │
│  │  • All modules work together                             │  │
│  │  • Data flows through analyzer                           │  │
│  │  • Results packaged as JSON                              │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Backend Architecture

### Entry Point: `src/index.js`
```javascript
// Express server initialization
- Creates Express app
- Sets up middleware (CORS, JSON parser)
- Defines routes:
  GET  /health         → Health check
  POST /api/analyze    → Main analysis endpoint
- Error handling middleware
- Starts server on port 5000
```

### URL Parser: `src/urlParser.js`
```javascript
// Parses URL and extracts features
parseURL(urlString) → {
  protocol,          // 'http' or 'https'
  hostname,          // 'example.com'
  domain,            // 'example.com'
  port,              // 443 or 80
  path,              // '/path/to/resource'
  length,            // URL character count
  subdomainCount,    // Number of subdomains
  parameterCount,    // Number of URL parameters
  specialCharacterCount,
  hyphenCount,       // Hyphens in domain
  dotCount,          // Dots in domain
  hasIPAddress,      // Is it an IP URL?
  hasAt,             // Does it contain @?
  isPunycode,        // Is it an IDN domain?
  suspiciousKeywords, // Matches against keyword list
  hasURLEncoding     // Contains % encoded chars?
}
```

**Suspicious Keywords Checked:**
```
login, signin, verify, verification, account, update,
secure, security, password, bank, payment, confirm,
wallet, paypal, amazon, apple, google, microsoft,
admin, authenticate
```

### Network Info: `src/networkInfo.js`
```javascript
// Retrieves DNS and IP information
getNetworkInfo(hostname) → {
  ipAddresses[],       // IPv4 addresses
  ipv6Addresses[],     // IPv6 addresses
  reverseDNS,          // Reverse DNS lookup result
  resolvedSuccessfully, // Did DNS resolve?
  error,               // Error message if failed
  dnsRecords: {}       // Additional DNS data
}

// Timeouts:
// - IPv4 lookup: 5 seconds
// - IPv6 lookup: 5 seconds
// - Reverse DNS: 3 seconds
```

### Risk Scorer: `src/riskScorer.js`
```javascript
// Calculates risk based on multiple indicators
calculateRiskScore(urlData, networkInfo) → {
  riskScore,      // 0-100 (capped)
  riskLevel,      // LOW, MEDIUM, HIGH, CRITICAL
  verdict,        // Safe or Suspicious
  indicators[],   // List of red flags
  details[]       // Detailed explanations
}

// Scoring System:
IP address URL                    → +30 points
HTTP instead of HTTPS             → +15 points
@ symbol in URL                   → +25 points
Punycode/IDN domain               → +15 points
Very long URL (>75 chars)         → +8 points
Excessive subdomains (>2)         → +12 points
Excessive hyphens (>2)            → +8 points
Suspicious keywords (per match)   → +8 points (max 20)
URL encoding present              → +5 points
Suspicious port (8080, 8000, etc) → +10 points
Excessive special characters (>5) → +5 points
DNS resolution failure            → +20 points
```

**Verdict Logic:**
```
Score ≥ 70  → CRITICAL    → SUSPICIOUS / POTENTIAL PHISHING
Score 40-69 → HIGH        → SUSPICIOUS / POTENTIAL PHISHING
Score 20-39 → MEDIUM      → LIKELY SAFE (with caution)
Score < 20  → LOW         → LIKELY SAFE
```

### Analyzer Orchestrator: `src/analyzer.js`
```javascript
// Coordinates all analysis steps
analyzeURL(urlString) → {
  url,
  domain,
  protocol,
  hostname,
  port,
  path,
  ipAddresses,
  ipv6Addresses,
  riskScore,
  riskLevel,
  verdict,
  indicators,
  urlCharacteristics: { ... },
  analysisDetails: [ ... ]
}

// Process Flow:
1. parseURL(urlString)         → URL components
2. getNetworkInfo(domain)      → Network data
3. calculateRiskScore(...)     → Risk assessment
4. Combine all data            → Full response
```

## Frontend Architecture

### App Structure: `src/App.jsx`
```
App (Root Component)
├── State Management
│   ├── results (analysis output)
│   ├── loading (processing state)
│   └── error (error messages)
├── Event Handlers
│   └── handleAnalyze(url)
├── Child Components
│   ├── URLAnalyzer (input)
│   └── ResultsDisplay (output)
└── API Communication
    └── fetch('/api/analyze', POST)
```

### URL Analyzer Component: `src/components/URLAnalyzer.jsx`
```
URLAnalyzer
├── State
│   └── url (form input)
├── UI Elements
│   ├── Text input field
│   └── Submit button
├── Event Handlers
│   ├── handleSubmit()
│   └── onChange()
└── Features
    ├── Form validation
    ├── Button disable on loading
    └── Placeholder text
```

### Results Display Component: `src/components/ResultsDisplay.jsx`
```
ResultsDisplay
├── Props: results (analysis data)
├── Sections
│   ├── Verdict Card
│   │   ├── Risk score (numerical)
│   │   ├── Risk meter (visual bar)
│   │   ├── Verdict text
│   │   └── Risk level badge
│   │
│   ├── URL Information Card
│   │   ├── Full URL
│   │   ├── Domain
│   │   ├── Protocol
│   │   ├── Hostname
│   │   ├── Port
│   │   └── URL length
│   │
│   ├── IP & DNS Information Card
│   │   ├── IPv4 addresses
│   │   ├── IPv6 addresses
│   │   └── Reverse DNS
│   │
│   ├── URL Characteristics Card
│   │   ├── Domain length
│   │   ├── Subdomain count
│   │   ├── Parameter count
│   │   ├── Hyphens in domain
│   │   ├── IP address detection
│   │   ├── Punycode detection
│   │   └── Suspicious keywords
│   │
│   ├── Security Indicators Card
│   │   └── List of red flags
│   │
│   └── Analysis Details Card
│       └── Detailed explanations
│
├── Visual Features
│   ├── Color coding
│   ├── Icons (✓, ⚠️, 🔍, etc.)
│   ├── Responsive grid layout
│   └── Badge styling
│
└── Conditional Rendering
    ├── Show/hide cards based on data
    └── Safe URL message when appropriate
```

## Communication Protocol

### Request Format
```http
POST /api/analyze HTTP/1.1
Host: localhost:5000
Content-Type: application/json

{
  "url": "https://example.com/path?param=value"
}
```

### Response Format (Success)
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "url": "string",
  "domain": "string",
  "protocol": "string",
  "hostname": "string",
  "port": number,
  "path": "string",
  "ipAddresses": ["string"],
  "ipv6Addresses": ["string"],
  "reverseDNS": "string or null",
  "riskScore": number (0-100),
  "riskLevel": "LOW|MEDIUM|HIGH|CRITICAL",
  "verdict": "string",
  "indicators": ["string"],
  "urlCharacteristics": {
    "length": number,
    "domainLength": number,
    "subdomainCount": number,
    "parameterCount": number,
    "specialCharacterCount": number,
    "hyphenCount": number,
    "dotCount": number,
    "hasIPAddress": boolean,
    "hasAt": boolean,
    "usesHTTPS": boolean,
    "isPunycode": boolean,
    "suspiciousKeywords": ["string"]
  },
  "analysisDetails": ["string"]
}
```

### Response Format (Error)
```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": "Error type",
  "message": "Detailed error message"
}
```

## Data Flow Diagram

```
User Input (URL)
    ↓
[Frontend: URLAnalyzer Component]
    ├─ Validate input
    ├─ Show loading state
    ↓
[Frontend → Backend: HTTP POST]
    ├─ Content-Type: application/json
    ├─ Body: { "url": "..." }
    ↓
[Backend: Express Route Handler]
    ├─ Validate request
    ├─ Extract URL
    ↓
[Backend: Analyzer Module]
    ├─ Calls parseURL()
    ├─ Calls getNetworkInfo()
    ├─ Calls calculateRiskScore()
    ├─ Combines results
    ↓
[Backend → Frontend: JSON Response]
    ├─ All analysis data
    ├─ Risk score & verdict
    ├─ URL characteristics
    ├─ Network info
    ↓
[Frontend: ResultsDisplay Component]
    ├─ Render verdict card
    ├─ Show risk meter
    ├─ Display indicators
    ├─ Show detailed analysis
    ↓
[User Views Results]
```

## Security Design

### Input Validation
```javascript
// URL Validation
1. Check if URL is provided
2. Ensure URL is a string
3. Parse URL using built-in URL class
4. Catch malformed URLs
5. Return user-friendly error
```

### Network Safety
```javascript
// DNS/Network Safety
1. Skip DNS resolution for IP addresses
2. Implement 5-second timeouts
3. Handle DNS failures gracefully
4. Catch and log errors
5. Continue analysis with limited data
```

### Error Handling
```javascript
// Three-Layer Error Handling
1. URL Parser errors (caught & reported)
2. Network errors (caught & reported)
3. Risk calculation errors (prevented by design)

// User-Facing Errors
- Invalid URL format
- Missing URL parameter
- Server errors (generic message)
```

### SSRF Prevention
```javascript
// Phishing URL Analysis = SSRF-Proof
- No actual HTTP requests to the URL
- Only DNS lookups (safe & standard)
- No content downloads
- No page rendering
- No JavaScript execution
```

## Performance Optimization

### Frontend
```javascript
// Load Time: ~2-3 seconds
- Vite bundle: Optimized JS/CSS
- React: Minimal re-renders
- CSS: Inline, no external files
- Assets: Minimal (no images, videos)

// Runtime Performance
- Component rendering: <100ms
- State updates: Instant
- API calls: Async (no blocking)
```

### Backend
```javascript
// Response Time: 100-600ms
- URL parsing: <10ms
- DNS resolution: 50-500ms (timeout)
- Risk calculation: <5ms
- JSON serialization: <10ms

// Optimization Techniques
- Async/await for network calls
- Promise.race() for timeouts
- No database queries
- No file I/O
- In-memory processing only
```

## Testing Strategy

### Unit Tests (Manual)
- URL parser with various inputs
- Risk scorer with different conditions
- Network info with DNS failures

### Integration Tests
- Frontend → Backend communication
- API response format validation
- Error handling and edge cases

### End-to-End Tests
- Complete user workflow
- Multiple URLs with different characteristics
- Error scenarios

## Code Quality

### Coding Standards
- ES6+ modern JavaScript
- Clear variable naming
- Minimal comments (self-documenting)
- Consistent formatting
- No console.log in production code

### Error Messages
- User-friendly
- No technical jargon
- Actionable guidance
- No stack traces exposed

### Logging
- Errors logged to console (development)
- Non-intrusive for users
- Optional file logging for production

## Deployment Considerations

### Frontend Deployment
- Build: `npm run build` → creates `dist/`
- Serve: Static HTTP server (nginx, Apache)
- No backend required after build
- Cache busting for updates

### Backend Deployment
- Runtime: Node.js v14+
- Process manager: PM2 (recommended)
- Port: Configurable via environment
- Scaling: Horizontal (stateless)

### Environment Setup
```bash
# Production Environment Variables
NODE_ENV=production
PORT=5000

# Optional
LOG_LEVEL=info
DNS_TIMEOUT=5000
```

---

This architecture ensures:
✅ Clean separation of concerns
✅ Easy to maintain and extend
✅ Scalable design
✅ Secure by default
✅ User-friendly experience
✅ Professional appearance
