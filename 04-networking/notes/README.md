# 🌐 Networking for DevOps — Complete Beginner's Guide

> **How to use this document:** This is your permanent reference. Read it top-to-bottom once. After that, use the chapter headers to jump to whatever you've forgotten. Every section starts with a plain-English explanation, adds the technical detail, shows real commands, and ends with a "Why DevOps cares" note.
>
> **The goal:** By the end of this document you will understand how data travels across the internet, how devices find each other, how DNS works end-to-end, how to subnet a network by hand, and how to diagnose almost any network problem using the command line. You will speak the language of networking confidently in interviews and on the job.
>
> **Mental model for the whole course:** Networking is just *getting data from one computer to another reliably.* Every concept — IP addresses, DNS, routing, subnets, ports — is a specific solution to one specific problem in that journey. Keep asking yourself: *"What problem does this thing solve?"*

---

# 📘 Chapter 1 — Introduction to Networking

## 1.1 What is a Network?

**Plain English:** A **network** is two or more devices connected so they can send information to each other.

That's the entire definition. Your phone and your Wi-Fi router form a network. A data center with 50,000 servers is a network. The internet is a network of millions of networks all connected together.

**The two core purposes of any network:**

| Purpose | What it means | Real example |
|---|---|---|
| **Communication** | Devices send messages to each other | Your browser requests a web page from a server |
| **Resource sharing** | Devices share files, printers, internet access | An office where everyone prints to one printer |

## 1.2 Why Networking Matters for DevOps — Specifically

This is not optional background knowledge. Every task you do as a DevOps engineer is a networking task:

- **Deploying an application** — you push code to a server over the network.
- **Connecting services** — your app talks to a database, a cache, an API. All over the network.
- **Exposing services to users** — DNS, load balancers, firewalls all involve networking.
- **Debugging production incidents** — "the site is down" is almost always a networking problem first.
- **Cloud infrastructure** — AWS VPCs, subnets, security groups, route tables are all networking concepts with a cloud wrapper.
- **Containers** — Docker networks, Kubernetes services and ingress are networking all the way down.

> **The uncomfortable truth:** A DevOps engineer who doesn't understand networking will be blocked constantly — by problems they can't diagnose, by concepts in documentation they don't recognise, by infrastructure they can't design. This chapter removes that blocker.

## 1.3 Types of Networks — LAN and WAN

Networks are categorised by geographic size. The two that matter most:

### LAN — Local Area Network

- **Covers:** A small physical area — one room, one building, one office floor.
- **Connects:** Devices close to each other so they share resources.
- **Speed:** Very fast — typically 1Gbps or 10Gbps inside a building.
- **Examples:** Your home Wi-Fi network. The office network at a company. The servers in a single data center rack.
- **Who manages it:** You — or your company's network team.

### WAN — Wide Area Network

- **Covers:** A large geographic area — cities, countries, the whole world.
- **Connects:** Multiple LANs together.
- **Speed:** Slower than LAN, because the distances are huge.
- **The biggest WAN:** The **internet** — a WAN connecting billions of LANs worldwide.
- **Who manages it:** ISPs (Internet Service Providers), telecoms companies, large cloud providers.

```
Your laptop (device)
    └── Home Wi-Fi (LAN)
          └── Your router
                └── ISP network (WAN)
                      └── Internet (the biggest WAN)
                            └── AWS data center (another LAN)
                                  └── The server running your app
```

> Other types exist — MAN (Metropolitan Area Network, e.g. a city), PAN (Personal Area Network, e.g. Bluetooth between your phone and headphones) — but LAN and WAN are the two you'll reference daily.

## 1.4 Core Network Hardware: Switches, Routers, Firewalls

These three devices appear in every network from a home Wi-Fi to a cloud data center. Each solves a different problem.

### Switch — "Traffic cop inside one building"

- **What it does:** Connects multiple devices **within the same network** (the same LAN).
- **How it works:** It learns each device's MAC address and only sends data to the specific port the destination device is connected to — not to everyone (that was the old "hub" — switches replaced hubs because of this).
- **Where you find it:** In offices, a switch connects all the desks. In data centers, a switch connects a rack of servers.
- **OSI layer:** Layer 2 (Data Link) — it works with MAC addresses.

### Router — "The bridge between buildings"

- **What it does:** Connects **different networks** together and moves data between them.
- **How it works:** It reads the destination IP address of every packet and decides which direction to send it — using its **routing table**.
- **Where you find it:** Your home router connects your LAN to your ISP's WAN. A cloud router connects your VPC subnets to the internet.
- **OSI layer:** Layer 3 (Network) — it works with IP addresses.

### Firewall — "The security gate"

- **What it does:** Monitors and controls all incoming and outgoing network traffic based on rules you define.
- **How it works:** It inspects each packet and either **allows** it or **drops** it based on rules (e.g. "block all traffic to port 22 from outside", "only allow port 443 in").
- **Types:**
  - **Network firewall** — a physical device or VM that sits at the edge of your network.
  - **Host-based firewall** — software running on a single machine (e.g. `ufw` or `iptables` on Linux).
  - **Cloud security groups** — AWS Security Groups are essentially stateful firewalls.
- **OSI layer:** Can work at Layer 3 (IP filtering), Layer 4 (port filtering), or Layer 7 (deep packet inspection).

| Device | Connects | Works with | OSI Layer |
|---|---|---|---|
| **Switch** | Devices within the same LAN | MAC addresses | 2 (Data Link) |
| **Router** | Different networks together | IP addresses | 3 (Network) |
| **Firewall** | Controls what can pass through | IPs and ports | 3–7 |

> In a home, all three are combined in the single box your ISP gives you. In cloud environments, they are separate software-defined components. Understanding what each does lets you configure them correctly regardless of the form they take.

## 1.5 IP Addresses — Logical Addresses

### What is an IP address?

An **IP address** (Internet Protocol address) is a **unique identifier assigned to a device on a network** so other devices know how to reach it.

- It is **logical** — assigned by software (or a DHCP server), not burned into hardware.
- It can **change** — when you join a different Wi-Fi, you get a new IP address.
- It works across the internet — routers use IP addresses to move your data from network to network.

> **Analogy:** An IP address is like a **postal address**. It tells the postal system (the internet) where to deliver the package. It's associated with a location, and if you move, your address changes.

### IPv4 — The original system

- **Format:** Four numbers (0–255) separated by dots.
- **Size:** 32 bits = 4 bytes.
- **Range:** `0.0.0.0` to `255.255.255.255`
- **Total addresses:** ~4.3 billion (2³²)
- **Example:** `192.168.1.100`

```
192   .   168   .   1   .   100
 8 bits   8 bits  8 bits  8 bits
         = 32 bits total
```

**The problem:** IPv4 ran out of addresses. There are more than 4.3 billion internet-connected devices in the world today. This is why NAT (Chapter 5) and IPv6 both exist.

### IPv6 — The replacement

- **Format:** Eight groups of four hexadecimal digits separated by colons.
- **Size:** 128 bits.
- **Total addresses:** ~340 undecillion (3.4 × 10³⁸) — essentially unlimited.
- **Example:** `2001:0db8:85a3:0000:0000:8a2e:0370:7334`
- **Shorthand:** Leading zeros in a group can be dropped, and consecutive all-zero groups can be replaced with `::`:
  `2001:db8:85a3::8a2e:370:7334`

| | IPv4 | IPv6 |
|---|---|---|
| **Size** | 32-bit | 128-bit |
| **Format** | Decimal, dotted (`192.168.1.1`) | Hexadecimal, colon-separated |
| **Total addresses** | ~4.3 billion | ~340 undecillion |
| **Still dominant?** | Yes, most traffic still IPv4 | Growing — all modern OSes support it |

### Private vs Public IP Addresses

Not all IP addresses are equal. Some are reserved for private networks only.

**Private IP ranges (not routable on the internet):**

| Range | CIDR | Common use |
|---|---|---|
| `10.0.0.0` – `10.255.255.255` | `10.0.0.0/8` | Large corporate networks, AWS VPCs |
| `172.16.0.0` – `172.31.255.255` | `172.16.0.0/12` | Medium networks, Docker default |
| `192.168.0.0` – `192.168.255.255` | `192.168.0.0/16` | Home networks, small offices |

**Special addresses:**
- `127.0.0.1` — **Loopback / localhost**. Always refers to the device itself. `ping 127.0.0.1` always works regardless of network connectivity.
- `0.0.0.0` — Means "all interfaces" or "any address" (used in routing and service binding).
- `255.255.255.255` — Broadcast to all devices on the local network.

> **Why DevOps cares:** When you see `10.0.x.x` or `192.168.x.x` in server logs, that's internal/private traffic. When you see a completely different address, that's a public IP. AWS EC2 instances have a private IP (internal) and often a public IP (internet-facing). Understanding which is which is fundamental to debugging connectivity.

## 1.6 MAC Addresses — Physical Addresses

### What is a MAC address?

A **MAC address** (Media Access Control address) is a **unique identifier permanently assigned to a network interface card (NIC)** — the physical hardware that connects a device to a network.

- It is **physical** — burned into the hardware at the factory. Every network card has one.
- It does **not change** when you move networks (unlike an IP address).
- It is **only relevant within a local network** — routers do not forward MAC addresses across the internet.
- **Format:** 48 bits, written as six pairs of hexadecimal digits separated by colons (or hyphens on Windows).
- **Example:** `00:1A:2B:3C:4D:5E`

```
00:1A:2B  :  3C:4D:5E
└────────┘   └────────┘
OUI             Device
(manufacturer)  (unique ID)
```

The first three bytes (the **OUI — Organizationally Unique Identifier**) identify the manufacturer. You can look up `00:1A:2B` and find which company made the card.

### IP address vs MAC address — the critical distinction

| | IP Address | MAC Address |
|---|---|---|
| **Type** | Logical (software-assigned) | Physical (hardware-assigned) |
| **Changes?** | Yes — when you move networks | No — permanent (though it can be spoofed) |
| **Scope** | Internet-wide routing | Local network only |
| **OSI Layer** | Layer 3 (Network) | Layer 2 (Data Link) |
| **Analogy** | Postal address (changes when you move) | Fingerprint (stays with you forever) |

> **How they work together:** When data travels from London to a server in Dublin, IP addresses guide it across the internet hop by hop. But at each individual hop — router to router, then router to server — the data is wrapped in a frame with MAC addresses for that specific local link. The IP address stays the same end-to-end; the MAC addresses change at every hop.

### ARP — How IP Maps to MAC

**ARP (Address Resolution Protocol)** is what figures out which MAC address goes with which IP address on a local network.

```
Your computer wants to send data to 192.168.1.50
but doesn't know its MAC address.

ARP Broadcast → "Who has 192.168.1.50? Tell 192.168.1.10"
ARP Reply      ← "192.168.1.50 is at 00:1A:2B:3C:4D:5E"

Your computer caches this in the ARP table.
```

```bash
# View your ARP table (IP → MAC mappings your computer knows)
arp -a
# or
ip neigh show
```

## 1.7 Ports & Protocols — TCP and UDP

### What is a Port?

A **port** is a **numbered logical endpoint** on a device that identifies a specific application or service.

One device has one IP address. But it runs many services simultaneously — a web server, an SSH server, a database. Ports are how the operating system knows which incoming packet belongs to which service.

- Port range: **0 to 65535**.
- **Well-known ports (0–1023):** Reserved for standard services. Require root to bind.
- **Registered ports (1024–49151):** Used by applications.
- **Dynamic/ephemeral ports (49152–65535):** Assigned temporarily to clients when they make outgoing connections.

> **Analogy:** The IP address is the **building**. The port is the **room number** inside that building. You address a letter to "Building 192.168.1.1, Room 443" — that's an HTTPS server.

### Ports every DevOps engineer must memorise

| Port | Protocol | Service | Notes |
|---|---|---|---|
| **20, 21** | FTP | File Transfer Protocol | 21=control, 20=data |
| **22** | SSH | Secure Shell | Remote server access |
| **23** | Telnet | Unencrypted remote access | Never use — everything is plaintext |
| **25** | SMTP | Simple Mail Transfer Protocol | Sending email |
| **53** | DNS | Domain Name System | TCP and UDP |
| **80** | HTTP | HyperText Transfer Protocol | Unencrypted web traffic |
| **110** | POP3 | Post Office Protocol | Receiving email (legacy) |
| **143** | IMAP | Internet Message Access Protocol | Receiving email |
| **443** | HTTPS | HTTP Secure | Encrypted web traffic |
| **3306** | MySQL | MySQL database | |
| **5432** | PostgreSQL | PostgreSQL database | |
| **6379** | Redis | Redis cache/database | |
| **8080** | HTTP-alt | Alternative HTTP | Common for dev servers, proxies |
| **27017** | MongoDB | MongoDB database | |

```bash
# See what's listening on your machine right now
ss -tuln
# or
netstat -tuln

# Check if a specific port is open on a remote host
nc -zv hostname 443
# -z = don't send data (just check), -v = verbose

# See which process owns a port
ss -tulnp
sudo lsof -i :80
```

### What is a Protocol?

A **protocol** is a **set of rules** that defines how data is formatted, transmitted, and received between two parties. Both sides must follow the same protocol for communication to work — like two people agreeing to speak the same language with the same grammar.

Protocols exist at every layer of the OSI model. HTTP defines how web requests and responses look. DNS defines how name lookups work. TCP defines how a reliable connection is established and maintained.

### TCP — Transmission Control Protocol

TCP is **connection-oriented** and **reliable**. It guarantees that data arrives, arrives in the correct order, and that errors are detected and fixed.

**The TCP Three-Way Handshake:**

Before any data is sent, TCP establishes a connection using a three-step process:

```
Client                         Server
  |                               |
  |──── SYN ──────────────────>  |   "I want to connect. My sequence starts at X."
  |                               |
  |  <──── SYN-ACK ─────────────  |   "OK. My sequence starts at Y. Got your X."
  |                               |
  |──── ACK ──────────────────>  |   "Got your Y. Connection established."
  |                               |
  |════ DATA FLOWS BOTH WAYS ════|
  |                               |
  |──── FIN ──────────────────>  |   "I'm done sending."
  |  <──── ACK ─────────────────  |
  |  <──── FIN ─────────────────  |   "I'm done too."
  |──── ACK ──────────────────>  |
  |                               |
        Connection closed
```

- **SYN** = synchronise (start connection)
- **ACK** = acknowledge (confirm receipt)
- **FIN** = finish (end connection)

**TCP characteristics:**
- **Reliable** — every packet is acknowledged. If acknowledgement doesn't come, the packet is retransmitted.
- **Ordered** — packets are numbered (sequence numbers). The receiver reassembles them in the correct order even if they arrive out of order.
- **Flow control** — TCP adjusts the sending rate so a fast sender doesn't overwhelm a slow receiver.
- **Error checking** — each segment has a checksum. Corrupted packets are retransmitted.
- **Slower** — all this reliability adds overhead. The handshake alone takes time before data flows.

**Use TCP for:** Web browsing (HTTP/HTTPS), email (SMTP, IMAP), file transfer (FTP, SCP, rsync), SSH, database connections.

### UDP — User Datagram Protocol

UDP is **connectionless** and **unreliable** (in the technical sense — it makes no guarantees). It just fires packets and moves on.

```
Client                         Server
  |                               |
  |──── DATA ─────────────────>  |   (no handshake, no acknowledgement)
  |──── DATA ─────────────────>  |
  |──── DATA ─────────────────>  |
  |                               |
  Lost packets are NOT retransmitted.
  Order is NOT guaranteed.
```

**UDP characteristics:**
- **Connectionless** — no setup, no handshake, just send.
- **No delivery guarantee** — packets can be lost. UDP doesn't care.
- **No ordering guarantee** — packets can arrive out of order.
- **Very fast** — no overhead, no waiting for acknowledgements.
- **Low latency** — critical for real-time applications.

**Use UDP for:** DNS lookups, video/audio streaming, online gaming, VoIP, VPN tunnels (e.g. WireGuard uses UDP).

> **The key insight about UDP in DNS:** DNS uses UDP by default because DNS queries and responses are small enough to fit in one packet. If that packet is lost, the application just asks again. The speed benefit far outweighs the tiny risk of packet loss. (DNS falls back to TCP for large responses like zone transfers.)

### TCP vs UDP — Complete Comparison

| Feature | TCP | UDP |
|---|---|---|
| **Connection** | Connection-oriented (3-way handshake) | Connectionless |
| **Reliability** | Guaranteed delivery | Best-effort, no guarantee |
| **Order** | Guaranteed in-order delivery | No ordering |
| **Speed** | Slower (overhead) | Faster (no overhead) |
| **Error checking** | Yes — retransmits on error | Checksum only, no retransmit |
| **Flow control** | Yes | No |
| **Header size** | 20+ bytes | 8 bytes |
| **Use when** | Correctness matters | Speed matters |
| **Examples** | HTTP, HTTPS, SSH, email, FTP | DNS, streaming, gaming, VoIP |

---

# 📗 Chapter 2 — The OSI Model

## 2.1 Why Does the OSI Model Exist?

Before the OSI model, every vendor built their networking equipment to their own proprietary standard. IBM equipment couldn't talk to Cisco equipment. An application had to understand the specific underlying network technology. This was chaos.

In 1984, the International Organization for Standardization (ISO) published the **OSI (Open Systems Interconnection) model** — a standard 7-layer framework describing how network communication should be structured.

**The three problems it solved:**

1. **Decoupled innovation** — each layer can evolve independently. Wi-Fi (Layer 1) gets faster without web browsers (Layer 7) needing to change. HTTPS (Layer 7) can change without Ethernet (Layer 2) caring.

2. **Simplified equipment management** — you can buy a switch from Cisco and a router from Juniper and they work together because they both speak the same layered language.

3. **Application independence** — applications don't need to know whether they're running on Wi-Fi, Ethernet, or Fibre. They hand data to the layers below and those layers handle the physical details.

> **Important:** The OSI model is a **conceptual framework** — a way to think about and discuss networking. Real networks run the TCP/IP model (4 layers). But everyone uses OSI's vocabulary. When someone says "this is a Layer 3 problem," they mean it's a routing/IP problem. Knowing OSI is how you speak the language of networking.

## 2.2 The 7 Layers — Complete Reference

Read from **Layer 7 down to Layer 1** — that's the order data is processed when an application sends something.

| # | Layer | Data unit | Key protocols | Job in one sentence |
|---|---|---|---|---|
| **7** | **Application** | Data | HTTP, FTP, SSH, SMTP, DNS | Provides network services directly to user applications |
| **6** | **Presentation** | Data | SSL/TLS, JPEG, MPEG, ASCII | Translates, encrypts, and compresses data |
| **5** | **Session** | Data | Sockets, NetBIOS, RPC | Manages and maintains connections between applications |
| **4** | **Transport** | Segments | TCP, UDP | End-to-end delivery; segmentation, reliability, flow control |
| **3** | **Network** | Packets | IP, ICMP, OSPF, BGP | Logical addressing and routing across networks |
| **2** | **Data Link** | Frames | Ethernet, Wi-Fi (802.11) | Node-to-node delivery on the same network; MAC addressing |
| **1** | **Physical** | Bits | Cables, fibre, radio waves | Transmits raw bits over the physical medium |

### Layer 1 — Physical

- **What it handles:** The actual physical transmission of raw bits — electrical signals on copper, light pulses on fibre, radio waves for Wi-Fi.
- **Components:** Network cables (Cat5e, Cat6), fibre optic cables, Wi-Fi radio transceivers, hubs, repeaters, network interface cards (the physical connector).
- **No intelligence here:** Layer 1 doesn't know what the bits mean. It just transmits 1s and 0s.
- **DevOps relevance:** "Is the cable plugged in?" is a Layer 1 question. In cloud environments, the physical layer is abstracted away — you never touch it directly.

### Layer 2 — Data Link

- **What it handles:** Reliable transfer of **frames** between two directly connected nodes. Error detection. MAC address-based addressing.
- **Divided into two sub-layers:**
  - **MAC (Media Access Control)** — controls how devices share the physical medium; uses MAC addresses for addressing.
  - **LLC (Logical Link Control)** — manages flow control and error checking.
- **Components:** Ethernet switches, Wi-Fi access points, MAC addresses.
- **DevOps relevance:** When you run `ip link show`, you're seeing Layer 2 interfaces. VLANs (Virtual LANs) operate at Layer 2 — they segment networks by tagging frames. ARP (resolving IP to MAC) operates at Layer 2.

### Layer 3 — Network

- **What it handles:** Logical addressing (IP addresses) and **routing** — determining the path packets take across multiple networks.
- **Key insight:** Layer 2 gets data from A to B on the same network. Layer 3 gets data from A to B across *different* networks, possibly via many intermediate routers.
- **Components:** Routers, IP addresses, ICMP.
- **DevOps relevance:** IP addresses, routing tables, subnets, VPCs — all Layer 3. When you configure an AWS route table or debug why two subnets can't talk, that's Layer 3.

### Layer 4 — Transport

- **What it handles:** End-to-end delivery. Segmentation (breaking large data into smaller pieces). Reassembly. Port numbers. TCP's reliability and flow control. UDP's speed.
- **Key protocols:** TCP and UDP (covered in detail in Chapter 1).
- **DevOps relevance:** Ports live at Layer 4. Firewalls that filter by port operate at Layer 4. Load balancers can operate at Layer 4 (routing by IP:port) or Layer 7 (routing by HTTP headers). When you configure a security group rule to allow port 443, you're working at Layer 4.

### Layer 5 — Session

- **What it handles:** Establishing, maintaining, and terminating sessions (ongoing conversations) between applications. Handles synchronisation.
- **Hardest layer to visualise:** In practice, session management is often handled by the application layer itself. Many people merge it mentally with Layers 6 and 7.
- **Examples:** When you log into a web app and stay logged in across multiple requests, that's session management.

### Layer 6 — Presentation

- **What it handles:** Data translation, encryption, and compression. Ensures data sent in one format can be read in another.
- **Examples:** TLS/SSL encryption/decryption happens here. JPEG compression. Character encoding (ASCII to UTF-8). Serialisation (converting an object to JSON or XML for transmission).
- **DevOps relevance:** SSL/TLS certificates, HTTPS encryption, and data serialisation formats all operate at this layer.

### Layer 7 — Application

- **What it handles:** The protocols that applications use to communicate. This is what end users (and developers) interact with directly.
- **Key protocols:** HTTP/HTTPS (web), SMTP (email), FTP (file transfer), DNS (name resolution), SSH (remote access).
- **DevOps relevance:** Everything you interact with at the application level — nginx configs, API calls, SSH — is Layer 7. Application-layer firewalls (WAFs) and Layer 7 load balancers inspect HTTP requests here.

> **Memory trick (7 → 1):** **"All People Seem To Need Data Processing"**
> Application, Presentation, Session, Transport, Network, Data Link, Physical

## 2.3 The TCP/IP Model — What Actually Runs the Internet

The TCP/IP model is the **practical, 4-layer model** the modern internet actually uses. It was developed before the OSI model (DARPA built it in the 1970s) and it's what's really implemented in every OS.

| TCP/IP Layer | Maps to OSI layers | Key protocols |
|---|---|---|
| **Application** | OSI 5, 6, 7 | HTTP, HTTPS, DNS, SMTP, SSH, FTP |
| **Transport** | OSI 4 | TCP, UDP |
| **Internet** | OSI 3 | IP, ICMP, ARP |
| **Network Access** (Link) | OSI 1, 2 | Ethernet, Wi-Fi, MAC |

> **Use OSI** to *talk about and troubleshoot* networking (its layer vocabulary is universal). **Use TCP/IP** to understand what's actually *implemented in code* and running on every device.

## 2.4 Data Encapsulation — What Actually Happens to Your Data

This is where the model becomes concrete. As data moves **down** the stack (sending), each layer **wraps** the data from the layer above in a new header (and sometimes a trailer). This is called **encapsulation**. Going **up** the stack (receiving), each layer **strips** its header — called **de-encapsulation**.

```
Application data
   ↓ Layer 7 adds: HTTP headers (GET / HTTP/1.1, Host: example.com...)
   ↓ Layer 4 adds: TCP header (source port, dest port, seq number, flags...)
   ↓ Layer 3 adds: IP header (source IP, destination IP, TTL...)
   ↓ Layer 2 adds: Ethernet header (source MAC, dest MAC) + trailer (checksum)
   ↓ Layer 1:      All of the above becomes electrical/optical/radio signals
```

On the receiving end, each layer strips its header and passes the payload up.

### Full Example: You type `https://google.com` and press Enter

**SENDER — down the stack (7 → 1):**

| Layer | What happens |
|---|---|
| **7 — Application** | Browser constructs an HTTPS GET request |
| **6 — Presentation** | TLS encryption is applied to the request |
| **5 — Session** | TCP/TLS session is established (or reused) |
| **4 — Transport** | Data is segmented; TCP SYN sent to **port 443**; source port e.g. 52841 assigned |
| **3 — Network** | Each segment wrapped in an IP packet; source IP (your IP) and destination IP (Google's IP) added |
| **2 — Data Link** | Each packet wrapped in a frame; source MAC (your NIC) and destination MAC (your router's NIC) added |
| **1 — Physical** | Frame converted to electrical signal (Ethernet), radio waves (Wi-Fi), or light (Fibre) and transmitted |

**RECEIVER — up the stack (1 → 7) at Google's server:**

| Layer | What happens |
|---|---|
| **1 — Physical** | Electrical/optical signal received and converted back to bits |
| **2 — Data Link** | Bits assembled into a frame; destination MAC checked — it's ours, keep it |
| **3 — Network** | Frame's Ethernet header stripped; IP packet extracted; destination IP checked — it's ours |
| **4 — Transport** | IP header stripped; TCP segment extracted; port 443 → this goes to the web server process; TCP sequence numbers used to reassemble in order |
| **5 — Session** | Connection session identified or established |
| **6 — Presentation** | TLS decryption applied |
| **7 — Application** | HTTP request handed to nginx/web server; it processes the GET and constructs a response |

> ⚠️ **The grain of salt:** Real implementations blur these lines. TLS spans layers 4–6. HTTP/3 (QUIC) uses UDP at layer 4 but implements its own reliability. The model is a thinking tool, not a rigid law.

## 2.5 The TCP Handshake — One More Look

Because understanding TCP is so important for debugging, let's look at it in `tcpdump` output — what you'd actually see on a real server:

```bash
# Capture TCP traffic to port 80
sudo tcpdump -i eth0 'tcp port 80' -n

# Output:
# 10.0.0.1.52841 > 93.184.216.34.80: Flags [S], seq 123456, win 65535
# 93.184.216.34.80 > 10.0.0.1.52841: Flags [S.], seq 987654, ack 123457, win 65535
# 10.0.0.1.52841 > 93.184.216.34.80: Flags [.], ack 987655
#
# Flags: S=SYN, .=ACK, F=FIN, R=RST, P=PUSH (data)
# [S]   = SYN
# [S.]  = SYN-ACK
# [.]   = ACK
```

Understanding `tcpdump` output is a core DevOps troubleshooting skill.

---

# 📙 Chapter 3 — DNS (Domain Name System)

## 3.1 The Problem DNS Solves

Every server on the internet has an IP address. `google.com` lives at `142.250.179.206`. But:

1. IP addresses are hard to remember.
2. IP addresses change — Google might move their servers. If you'd bookmarked `142.250.179.206`, you'd break immediately.
3. One domain can map to hundreds of IPs (load balancing) and that mapping changes constantly.

**DNS solves all three problems.** You remember the name. DNS handles the number. When Google changes their IP, they update DNS. You notice nothing.

> **Analogy:** DNS is the **phone book of the internet.** You know the name of who you want to call. The phone book gives you their number. If they change numbers, they update the phone book — you just look up the name again.

## 3.2 What is DNS?

**DNS = Domain Name System.**

A **distributed, hierarchical, globally replicated database** that translates human-readable **domain names** into **IP addresses** (and provides other information about domains).

- **Distributed** — no single server holds all records. Responsibility is spread across thousands of servers worldwide.
- **Hierarchical** — organised as a tree with a root at the top.
- **Replicated** — records are cached everywhere for speed and resilience.

## 3.3 DNS Components Deep Dive

### Nameservers

**Nameservers** are the servers that answer DNS queries. Two types:

**Authoritative Nameserver:**
- Holds the **official, definitive records** for a domain.
- When someone asks "what's the IP for `api.example.com`?", the authoritative nameserver gives the final answer.
- You configure authoritative nameservers when you buy a domain — you point the domain to these servers (usually via your domain registrar's settings).
- Examples: AWS Route 53, Cloudflare DNS, your own `bind9` server.

**Recursive Resolver (Recursive Nameserver):**
- The middleman between your computer and the authoritative nameservers.
- Your computer doesn't talk to authoritative servers directly. It talks to a recursive resolver, which does the legwork of finding the answer.
- Caches results to avoid repeating work.
- Examples: Your ISP's DNS server (`8.8.8.8` is Google's resolver, `1.1.1.1` is Cloudflare's).

```
Your computer → Recursive Resolver → (Root → TLD → Authoritative)
                 (your ISP or 8.8.8.8)    (the actual answer)
```

### Zone Files

A **zone file** is a text file that holds all the DNS records for a domain. It lives on the authoritative nameserver.

Here's what a real zone file looks like:

```
; Zone file for example.com
$ORIGIN example.com.
$TTL 3600                        ; default TTL: 1 hour

; SOA record (Start of Authority)
@    IN  SOA  ns1.example.com.  admin.example.com. (
              2024011501  ; Serial (date + increment)
              7200        ; Refresh (2 hours)
              3600        ; Retry (1 hour)
              1209600     ; Expire (2 weeks)
              300 )       ; Minimum TTL (5 min)

; Nameserver records
@         IN  NS    ns1.example.com.
@         IN  NS    ns2.example.com.

; A records (IPv4)
@         IN  A     93.184.216.34
www       IN  A     93.184.216.34
api       IN  A     10.0.1.50
mail      IN  A     93.184.216.50

; AAAA record (IPv6)
@         IN  AAAA  2606:2800:220:1:248:1893:25c8:1946

; CNAME records
blog      IN  CNAME www.example.com.
ftp       IN  CNAME www.example.com.

; MX records (mail servers)
@         IN  MX    10  mail.example.com.
@         IN  MX    20  backup-mail.example.com.

; TXT records
@         IN  TXT   "v=spf1 include:_spf.google.com ~all"
@         IN  TXT   "google-site-verification=abc123xyz"
```

## 3.4 DNS Record Types — In Depth

### A Record — IPv4 address

- **Maps:** domain name → IPv4 address
- **The most common record type.**
- Can have multiple A records for the same name (round-robin load balancing).

```bash
# Query an A record
dig A google.com
# or
nslookup google.com

# Example output meaning: google.com maps to 142.250.179.206
```

### AAAA Record — IPv6 address

- **Maps:** domain name → IPv6 address
- Same as A but for IPv6.
- Named "AAAA" because IPv6 is 4× the size of IPv4 (4 × A = AAAA).

```bash
dig AAAA google.com
```

### CNAME Record — Canonical Name (Alias)

- **Maps:** one domain name → another domain name (not an IP address directly).
- The browser follows the chain: CNAME → eventually an A record → IP.
- **Use case:** Point `www.example.com` → `example.com` so you only update one A record when the IP changes.
- **Restriction:** A CNAME cannot coexist with other records at the same name. So you can't put a CNAME on the root domain (`example.com`). AWS Route 53 has an "ALIAS" record type that works around this.

```bash
dig CNAME www.google.com
# www.google.com is a CNAME to google.com
```

### MX Record — Mail Exchanger

- **Maps:** domain → mail server(s) responsible for receiving email.
- Includes a **priority value** (lower number = higher priority, tried first).
- Has multiple records for redundancy — if the primary mail server is down, email goes to the secondary.

```bash
dig MX gmail.com
# gmail.com MX 5 gmail-smtp-in.l.google.com.
# gmail.com MX 10 alt1.gmail-smtp-in.l.google.com.
# (try priority 5 first, then 10 if that fails)
```

### NS Record — Name Server

- **Maps:** domain → authoritative nameservers for that domain.
- These tell the internet "to get definitive DNS records for `example.com`, ask these servers."
- Set at your domain registrar when you buy a domain.

```bash
dig NS example.com
# example.com NS ns1.example.com.
# example.com NS ns2.example.com.
```

### TXT Record — Text

- **Contains:** Arbitrary text. Used for many purposes that don't fit other record types.
- **SPF (Sender Policy Framework):** Lists mail servers authorised to send email for the domain. Prevents email spoofing.
- **DKIM:** Email signing keys.
- **Domain verification:** Services like Google Search Console ask you to add a TXT record to prove you own the domain.

```bash
dig TXT google.com
```

### PTR Record — Pointer (Reverse DNS)

- **Maps:** IP address → domain name. The *reverse* of an A record.
- Used by mail servers to check if the sending IP matches the domain (anti-spam).
- Lives in a special domain: `in-addr.arpa` (for IPv4).
- Example: The PTR for `93.184.216.34` lives at `34.216.184.93.in-addr.arpa`.

```bash
# Reverse DNS lookup
dig -x 8.8.8.8
# or
nslookup 8.8.8.8
```

### SOA Record — Start of Authority

- **Contains:** Core administrative information about a zone — which nameserver is primary, contact email, serial number (for zone transfers), and various timing values (refresh, retry, expire, TTL).
- There's exactly one SOA per zone.
- The **serial number** is incremented every time the zone changes — secondary nameservers use this to know when to refresh their copy.

### Complete DNS Record Reference

| Record | Maps | Common use |
|---|---|---|
| **A** | Name → IPv4 | Standard hostname resolution |
| **AAAA** | Name → IPv6 | IPv6 hostname resolution |
| **CNAME** | Name → Name | Aliases, `www` redirect |
| **MX** | Domain → mail server | Email delivery |
| **NS** | Domain → nameservers | Delegation |
| **TXT** | Domain → text | SPF, DKIM, verification |
| **PTR** | IP → Name | Reverse DNS, anti-spam |
| **SOA** | Zone → admin info | Zone management |
| **SRV** | Service → server:port | Service discovery (used by SIP, XMPP, Kubernetes) |

## 3.5 How DNS Resolution Works — End to End

Let's resolve `www.example.com` and follow every step:

```
Step 1: Your browser asks the OS resolver:
        "What's the IP of www.example.com?"

Step 2: OS checks /etc/hosts
        If found → use it. Done.
        If not found → ask the recursive resolver.

Step 3: OS asks the configured recursive resolver (e.g. 8.8.8.8):
        "What's the IP of www.example.com?"

Step 4: Recursive resolver checks its cache.
        If cached and not expired (TTL not reached) → return cached answer. Done.
        If not cached → start the resolution process.

Step 5: Recursive resolver asks a Root Server:
        "Who handles .com?"
        Root replies: "Ask the .com TLD servers. Here are their addresses."
        (There are 13 root server clusters: a.root-servers.net through m.root-servers.net)

Step 6: Recursive resolver asks the .com TLD server:
        "Who handles example.com?"
        TLD replies: "Ask ns1.example.com and ns2.example.com."

Step 7: Recursive resolver asks ns1.example.com (authoritative):
        "What's the A record for www.example.com?"
        Authoritative replies: "93.184.216.34, TTL 3600"

Step 8: Recursive resolver caches the answer for 3600 seconds (1 hour).
        Returns 93.184.216.34 to your OS.

Step 9: Your OS caches the answer.
        Returns 93.184.216.34 to the browser.

Step 10: Browser connects to 93.184.216.34 on port 443 (HTTPS).
```

> **Caching is critical:** Without caching, every DNS query would go through this entire process. In reality, most queries are served from cache in milliseconds. The **TTL (Time To Live)** on each record controls how long it can be cached before requiring a fresh lookup.

### TTL — Time To Live

TTL is measured in seconds. Every DNS record has one.

| TTL | Duration | When to use |
|---|---|---|
| **300** | 5 minutes | Frequent changes, failover scenarios |
| **3600** | 1 hour | Normal stable records |
| **86400** | 24 hours | Very stable records |
| **0** | No caching | Testing only |

> **DevOps gotcha:** If you change a DNS record but it had a TTL of 86400, the old value will be cached everywhere for up to 24 hours. **Before a migration or failover, reduce the TTL to 300 first** (24 hours in advance so the change propagates). After the migration, raise it back.

## 3.6 DNS Debugging — `nslookup` and `dig` In Depth

These are the two DNS diagnostic tools every DevOps engineer uses constantly.

### `nslookup`

```bash
# Basic A record lookup
nslookup google.com

# Query a specific record type
nslookup -type=MX gmail.com
nslookup -type=NS example.com
nslookup -type=TXT example.com
nslookup -type=AAAA google.com

# Query a specific DNS server (not your default one)
nslookup google.com 8.8.8.8

# Reverse lookup (IP → name)
nslookup 8.8.8.8

# Interactive mode (type server, then domains)
nslookup
> server 1.1.1.1
> google.com
> exit
```

### `dig` — The Professional's DNS Tool

`dig` gives far more detail than `nslookup` and is preferred for debugging.

```bash
# Basic A record query
dig google.com

# The output explained:
; <<>> DiG 9.18.1 <<>> google.com
;; QUESTION SECTION:
;google.com.                    IN      A          ← what we asked

;; ANSWER SECTION:
google.com.             300     IN      A       142.250.179.206
#            ^TTL(secs)                  ^record  ^answer

;; AUTHORITY SECTION:
google.com.             345600  IN      NS      ns1.google.com.
(which nameservers are authoritative for this domain)

;; ADDITIONAL SECTION:
(IP addresses of those nameservers, if provided)

;; Query time: 12 msec                ← how long the lookup took
;; SERVER: 127.0.0.53#53(...)         ← which resolver answered
;; MSG SIZE  rcvd: 55                 ← response size in bytes
```

```bash
# Query specific record types
dig MX gmail.com
dig NS example.com
dig TXT google.com
dig AAAA google.com
dig SOA example.com

# Reverse lookup (PTR)
dig -x 8.8.8.8

# Query a specific DNS server
dig @8.8.8.8 google.com
dig @1.1.1.1 example.com

# Short answer only (just the IP)
dig +short google.com

# Full trace — watch the entire resolution process from root down
dig +trace google.com

# Check if propagation has happened (check multiple servers)
dig @8.8.8.8 example.com
dig @1.1.1.1 example.com
dig @208.67.222.222 example.com

# No recursion (only ask the nameserver directly, don't recurse)
dig +norecurse @ns1.example.com example.com

# Get all records (any type)
dig ANY example.com
```

### Real Debugging Scenarios

**Scenario 1: "Our website is down. Is it DNS?"**

```bash
# Step 1: Can we resolve the domain at all?
dig +short api.example.com
# If no answer → DNS problem

# Step 2: Compare what different resolvers return (is it propagated?)
dig +short @8.8.8.8 api.example.com
dig +short @1.1.1.1 api.example.com
# If they differ → DNS change is still propagating

# Step 3: Query the authoritative server directly (bypass caching)
dig NS example.com +short              # find authoritative servers
dig @ns1.example.com api.example.com  # ask authoritative directly

# Step 4: If the IP resolves, is the server actually responding?
ping 93.184.216.34
nc -zv 93.184.216.34 443
```

**Scenario 2: "Email isn't being delivered to our domain"**

```bash
# Check MX records
dig MX example.com

# Check that MX hostname resolves to an IP
dig A mail.example.com

# Check SPF record (anti-spam)
dig TXT example.com | grep spf
```

**Scenario 3: "After our deployment, some users see the old site and some see the new one"**

```bash
# Check TTL of the A record — if high, old value is still cached
dig A example.com
# Look at the TTL number (e.g. 86399) — that's how many seconds old the cached value is

# Check what different resolvers return
dig @8.8.8.8 example.com +short
dig @1.1.1.1 example.com +short
# Different answers = propagation still in progress
```

## 3.7 The `/etc/hosts` File

### What is it?

A local plain-text file on every Unix/Linux machine that maps domain names to IP addresses. Checked **before DNS**. Think of it as your personal, local DNS override.

```bash
cat /etc/hosts
# Output:
127.0.0.1   localhost
127.0.1.1   my-laptop
::1         localhost ip6-localhost

# You can add your own entries:
192.168.1.100  devserver
192.168.1.101  database
```

### Format

```
IP_address  hostname  [optional_aliases]
127.0.0.1   example.com  www.example.com
```

### Practical uses for DevOps engineers

**Local development — use friendly names instead of IPs:**

```bash
sudo vim /etc/hosts
# Add:
127.0.0.1    api.local
127.0.0.1    app.local
192.168.64.2  dev-vm
```

Now `curl http://api.local` hits your local server.

**Test a migration before DNS propagates:**

```bash
# Before changing real DNS, test that the new server works
sudo vim /etc/hosts
# Add:
NEW_SERVER_IP  example.com www.example.com
# Now your browser goes to the new server even though DNS still points to the old one
# Test thoroughly, then remove the line and change real DNS
```

**Block domains (poor man's ad blocker):**

```bash
# Redirect tracking domains to localhost (nothing there)
0.0.0.0  ads.tracker.com
```

```bash
# Apply changes (macOS)
sudo dscacheutil -flushcache

# Apply changes (Linux — flush the nscd cache)
sudo systemd-resolve --flush-caches
# or restart nscd
sudo systemctl restart nscd
```

> **The "why is it resolving to the wrong IP" gotcha:** When a domain resolves to an unexpected IP on one machine, always check `/etc/hosts` first. A forgotten test entry from months ago is a classic cause of "why does this work on my machine but not on the server?"

---

# 📕 Chapter 4 — Routing

## 4.1 What is Routing?

**Plain English:** Routing is the process of **choosing the path data takes from source to destination across multiple networks.**

The internet is not a direct connection between you and every server. It's a vast mesh of millions of interconnected networks. When you request `google.com`, your data might hop through your home router, your ISP's network, a backbone provider's network, Google's edge network, and finally Google's data center. Each of those "hops" is decided by a router.

> **Analogy:** Routing is like a **GPS for data packets.** Each router is an intersection. It knows its local map (routing table) and sends the packet in the right direction — toward the destination. The next router does the same. Eventually the packet arrives.

**How a router makes decisions:**

1. A packet arrives at the router.
2. The router reads the **destination IP address** from the packet's header.
3. The router looks up that IP in its **routing table**.
4. The routing table has entries like "to reach network 10.0.2.0/24, send out interface eth1 via gateway 192.168.1.1".
5. The router forwards the packet accordingly.
6. This repeats at every router until the packet reaches its destination.

```bash
# View your machine's routing table
ip route show
# or (older syntax)
route -n

# Example output:
default via 192.168.1.1 dev eth0        ← all unknown traffic goes to your router
192.168.1.0/24 dev eth0 proto kernel    ← your LAN is directly reachable
10.0.0.0/8 via 10.8.0.1 dev tun0       ← VPN route
```

### Why Routing Matters for DevOps

- **Cloud VPC routing** — in AWS, you configure route tables to control how traffic moves between subnets, to the internet (via Internet Gateway), and to on-premises (via VPN or Direct Connect).
- **Multi-region deployments** — traffic routing between regions affects latency and failover.
- **Container networking** — Kubernetes uses complex routing rules to move traffic between pods and services.
- **Debugging "why can't server A reach server B"** — usually a routing problem (wrong route table, missing route, or a firewall blocking the path).

## 4.2 Static vs Dynamic Routing

### Static Routing

Routes are **manually typed in by a human.** The router (or your machine) has fixed instructions: "to reach 10.2.0.0/16, send via 192.168.1.254."

```bash
# Add a static route (Linux)
sudo ip route add 10.2.0.0/16 via 192.168.1.254

# Add a persistent static route (add to /etc/network/interfaces or netplan config)
# In /etc/netplan/00-installer-config.yaml:
# network:
#   ethernets:
#     eth0:
#       routes:
#         - to: 10.2.0.0/16
#           via: 192.168.1.254

# Delete a static route
sudo ip route del 10.2.0.0/16

# View routing table
ip route show
```

**When to use static routing:**
- Small, simple, stable networks where routes never change.
- Specific overrides — "always send traffic to this subnet via this specific gateway."
- Cloud route tables — AWS route tables are essentially static routing, configured through the console or Terraform.
- When you have full control and the simplicity is valuable.

**Disadvantages:**
- Does not adapt to failures. If the gateway goes down, traffic stops — the route doesn't automatically switch.
- Doesn't scale. You can't manually manage routes for thousands of networks.

### Dynamic Routing

Routes are **learned and updated automatically** by running **routing protocols** that let routers share information with each other.

- Routers discover their neighbours.
- They exchange information about which networks they can reach.
- They calculate the best path using algorithms.
- If a link fails, they recalculate and update routes automatically.

**When to use dynamic routing:**
- Large, complex networks with many routers.
- Networks that need automatic failover when a link goes down.
- Internet-scale routing between organisations.

| | Static | Dynamic |
|---|---|---|
| **Configured by** | Humans, manually | Routing protocols, automatically |
| **Adapts to failures** | No — breaks | Yes — reroutes automatically |
| **Scalability** | Poor (can't manage at scale) | Excellent |
| **Complexity** | Simple to understand | Complex to configure |
| **Overhead** | None | Routers use bandwidth/CPU exchanging routing info |
| **Best for** | Small networks, simple cases | Large networks, ISPs, enterprises |

## 4.3 Routing Protocols — OSPF and BGP

### OSPF — Open Shortest Path First

- **Type:** Interior Gateway Protocol (IGP) — used **inside** a single organisation's network.
- **Algorithm:** Dijkstra's Shortest Path First algorithm — computes the least-cost path to every destination.
- **How it works:**
  - Every router builds a complete map of the network (a "Link State Database").
  - Each router runs Dijkstra's algorithm on this map to compute the best path to every destination.
  - When the network changes (a link goes down), routers flood the change to all other routers within seconds, and all routers recalculate.
- **Metric:** "Cost" — typically based on link bandwidth. A 10Gbps link has lower cost than a 1Mbps link.
- **Used in:** Corporate networks, data centers, ISP internal networks.

> **DevOps relevance:** You probably won't configure OSPF directly, but understanding it helps when working with on-premises infrastructure, cloud Direct Connect configurations, and network teams. If "OSPF is not converging" is in a ticket, you know it means the routers disagree on the network topology.

### BGP — Border Gateway Protocol

- **Type:** Exterior Gateway Protocol (EGP) — used **between** different organisations' networks.
- **The protocol that runs the internet.** Every ISP, cloud provider, and large organisation uses BGP to exchange routing information with other networks.
- **How it works:**
  - Networks are identified by **AS Numbers (Autonomous System Numbers)** — a unique number assigned to each organisation's network. AWS has an ASN. Google has an ASN. Your ISP has one.
  - BGP routers (called "BGP peers" or "BGP speakers") establish TCP sessions with routers in neighbouring networks.
  - They exchange **BGP UPDATE messages** advertising which IP prefixes they can reach.
  - Each router selects the best path using a complex set of criteria (AS path length, local preference, MED, etc.).
- **Very slow to converge** — by design. BGP is conservative to avoid instability.

**DevOps relevance:**
- AWS Direct Connect and VPN use BGP.
- Cloudflare, Fastly, and other CDNs use BGP to route users to the nearest edge.
- "BGP route leak" or "BGP hijack" makes the news occasionally (major internet outages).
- If your company does anything at ISP scale, you'll work with BGP.

| | OSPF | BGP |
|---|---|---|
| **Scope** | Inside one organisation | Between organisations |
| **Type** | Link-state (knows full topology) | Path-vector (knows AS paths) |
| **Speed** | Fast convergence (seconds) | Slow convergence (minutes) |
| **Metric** | Cost (bandwidth-based) | AS path + policy |
| **Used by** | Enterprises, data centers | ISPs, cloud providers, internet |

---

# 📒 Chapter 5 — Subnetting

> This is the chapter beginners find hardest. Work through it slowly. The payoff is huge: once subnetting clicks, every cloud networking concept (VPCs, subnets, security groups, NACLs) immediately makes sense because they're all just subnetting with a cloud management layer on top.

## 5.1 Why Subnetting Exists

Imagine a network with 1000 devices all on the same network. Every time any device sends a broadcast message (ARP, DHCP, etc.), all 1000 devices receive it. The network becomes a giant noisy room where everyone talks to everyone. Performance degrades. Security is impossible — every device can directly reach every other device.

**Subnetting** solves this by **dividing one large network into smaller, isolated sub-networks (subnets).**

Benefits:
- **Performance** — broadcasts stay within a subnet, not across the whole network.
- **Security** — you can put your database servers in a subnet with no internet access. Web servers in a public subnet. Management interfaces in a private subnet. Firewalls (or AWS NACLs) control traffic between subnets.
- **Organisation** — logical grouping. All your web servers in one subnet, databases in another, etc.
- **IP address efficiency** — allocate only the address space you need to each subnet.

> **Analogy:** A network is a big open office. Subnetting is adding internal walls to create separate rooms (HR, Engineering, Finance). The walls (routers/firewalls) control who can walk between rooms.

## 5.2 Understanding Binary and IP Addresses

You cannot truly understand subnetting without a little binary. Stick with it — it's simpler than it looks.

### Binary Basics

Binary is the base-2 number system. Only two digits: **0 and 1.**

Each position in a binary number represents a **power of 2**, doubling as you move left:

```
Position:   7    6    5    4    3    2    1    0
Value:    128   64   32   16    8    4    2    1
```

To convert binary to decimal: multiply each bit by its position value and add.

**Example: `11001010`**

```
Bit:     1    1    0    0    1    0    1    0
Value: 128   64   32   16    8    4    2    1

= (1×128) + (1×64) + (0×32) + (0×16) + (1×8) + (0×4) + (1×2) + (0×1)
= 128 + 64 + 0 + 0 + 8 + 0 + 2 + 0
= 202
```

**To convert decimal to binary:** repeatedly divide by 2, collect remainders:

```
202 ÷ 2 = 101 remainder 0
101 ÷ 2 = 50  remainder 1
50  ÷ 2 = 25  remainder 0
25  ÷ 2 = 12  remainder 1
12  ÷ 2 = 6   remainder 0
6   ÷ 2 = 3   remainder 0
3   ÷ 2 = 1   remainder 1
1   ÷ 2 = 0   remainder 1

Read remainders bottom to top: 11001010 ✓
```

### The 8-bit Octet — Why 0 to 255

An IPv4 address is **32 bits**, written as **four 8-bit groups (octets)** separated by dots for readability.

With 8 bits, the maximum value is `11111111` = `255`. The minimum is `00000000` = `0`. So each octet ranges from **0 to 255**.

```
192.168.1.100

192 = 11000000
168 = 10101000
1   = 00000001
100 = 01100100

Full binary: 11000000.10101000.00000001.01100100
```

### Subnet Masks in Binary — What They Actually Are

A **subnet mask** is a 32-bit number where the **left side is all 1s** (the network portion) and the **right side is all 0s** (the host portion).

```
Subnet mask 255.255.255.0 in binary:
11111111.11111111.11111111.00000000
└──────────────────────────┘└──────┘
         Network portion     Host
         (24 bits of 1s)   (8 bits of 0s)
```

The subnet mask tells you: "the first 24 bits of every IP address in this network must match — those bits identify the network. The last 8 bits are free to be anything — those identify individual hosts."

**This is literally all a subnet mask is.**

## 5.3 CIDR Notation

**CIDR = Classless Inter-Domain Routing.** Introduced in 1993 to replace the old class-based system.

CIDR notation: `IP_address/prefix_length`

The **prefix length** (the number after `/`) tells you how many **leading bits** are the network portion.

```
192.168.1.0/24

↓ means:
192.168.1.0 with subnet mask 11111111.11111111.11111111.00000000
= 24 bits for network, 8 bits for hosts
= subnet mask 255.255.255.0
```

### CIDR to Subnet Mask Conversion Table

| CIDR | Subnet Mask | Network bits | Host bits | Hosts per subnet |
|---|---|---|---|---|
| /8 | 255.0.0.0 | 8 | 24 | 16,777,214 |
| /16 | 255.255.0.0 | 16 | 16 | 65,534 |
| /24 | 255.255.255.0 | 24 | 8 | 254 |
| /25 | 255.255.255.128 | 25 | 7 | 126 |
| /26 | 255.255.255.192 | 26 | 6 | 62 |
| /27 | 255.255.255.224 | 27 | 5 | 30 |
| /28 | 255.255.255.240 | 28 | 4 | 14 |
| /29 | 255.255.255.248 | 29 | 3 | 6 |
| /30 | 255.255.255.252 | 30 | 2 | 2 |
| /32 | 255.255.255.255 | 32 | 0 | 1 (single host) |

> **Hosts per subnet = 2^(host bits) − 2.** Subtract 2 because the network address (all host bits = 0) and broadcast address (all host bits = 1) are reserved and cannot be assigned to devices.

## 5.4 Calculating Subnets — Step by Step

### The fundamental formula

```
Starting with: IP_address/prefix
Borrowing N bits from the host portion:
  - Creates 2^N new subnets
  - New prefix = original prefix + N
  - Each new subnet has (original host bits − N) host bits
  - Hosts per new subnet = 2^(original host bits − N) − 2
```

### Worked Example 1: Divide 192.168.1.0/24 into 4 equal subnets

**Step 1: How many bits do we need to borrow?**
We need 4 subnets. 2^N ≥ 4 → N = 2 (because 2² = 4).

**Step 2: New prefix length = 24 + 2 = /26**

**Step 3: New subnet mask**
`/26` = 26 bits of 1s:
`11111111.11111111.11111111.11000000` = `255.255.255.192`

**Step 4: Block size** = 2^(host bits) = 2^6 = **64**
(Each subnet contains 64 addresses — 62 usable)

**Step 5: List the subnets**

| Subnet | Network address | First usable | Last usable | Broadcast |
|---|---|---|---|---|
| 1 | 192.168.1.0/26 | 192.168.1.1 | 192.168.1.62 | 192.168.1.63 |
| 2 | 192.168.1.64/26 | 192.168.1.65 | 192.168.1.126 | 192.168.1.127 |
| 3 | 192.168.1.128/26 | 192.168.1.129 | 192.168.1.190 | 192.168.1.191 |
| 4 | 192.168.1.192/26 | 192.168.1.193 | 192.168.1.254 | 192.168.1.255 |

### Worked Example 2: Typical AWS VPC Design

You have a VPC: `10.0.0.0/16`. You want:
- 1 public subnet per availability zone (3 AZs)
- 1 private subnet per AZ
- Each subnet must hold at least 100 hosts

**Planning:**
- 6 subnets total.
- 2^N ≥ 6 → N = 3 (2³ = 8, the next power of 2 ≥ 6)
- New prefix = 16 + 3 = /19
- Hosts per /19 = 2^13 − 2 = 8190 (more than enough)
- Block size = 8192

| Subnet | Purpose | CIDR |
|---|---|---|
| Public AZ-a | Web servers | 10.0.0.0/19 |
| Public AZ-b | Web servers | 10.0.32.0/19 |
| Public AZ-c | Web servers | 10.0.64.0/19 |
| Private AZ-a | App servers | 10.0.96.0/19 |
| Private AZ-b | App servers | 10.0.128.0/19 |
| Private AZ-c | App servers | 10.0.160.0/19 |

### The Mental Shortcut

Once you know the prefix length, the **block size** (how many addresses per subnet) is always **2^(32−prefix)**:

- /24 → 2^8 = **256** addresses per subnet
- /25 → 2^7 = **128** addresses
- /26 → 2^6 = **64** addresses
- /27 → 2^5 = **32** addresses
- /28 → 2^4 = **16** addresses

And subnets always start at multiples of the block size:
- /26 (block=64): subnets start at 0, 64, 128, 192
- /27 (block=32): subnets start at 0, 32, 64, 96, 128, 160, 192, 224

### Determining if an IP is in a subnet

**Question:** Is `10.0.1.50` in the network `10.0.1.0/26`?

Network: `10.0.1.0`, block size 64. The subnet covers .0 through .63. 
50 is between 0 and 63. → **Yes, it is in this subnet.**

Or do it in binary:
```
Network:  10.0.1.0   = 00001010.00000000.00000001.00000000  /26
IP:       10.0.1.50  = 00001010.00000000.00000001.00110010

Compare first 26 bits:
00001010.00000000.00000001.00  ← network (both match)
                              ↑ remaining bits differ (host portion — that's fine)
→ Same network. Yes, it's in the subnet.
```

```bash
# Use ipcalc to verify (install with: sudo apt install ipcalc)
ipcalc 10.0.1.0/26
ipcalc 192.168.1.0/24

# Use python for quick subnet math
python3 -c "import ipaddress; n = ipaddress.ip_network('192.168.1.0/26'); print(list(n.hosts()))"
```

## 5.5 NAT — Network Address Translation

### The Problem

There are only ~4.3 billion IPv4 addresses. There are billions more internet-connected devices. Every device needs to reach the internet. But not every device can have a unique public IP address — there aren't enough.

### The Solution: Private IP Ranges + NAT

Devices in a home or office use **private IP addresses** (from the ranges in section 1.5). These are not unique globally — every home network might use `192.168.1.x`. But that's fine, because private IPs are only used inside the local network. They're never seen on the internet.

**NAT (Network Address Translation)** is the mechanism that lets many private IPs share **one public IP address** for internet access.

### How NAT Works — Step by Step

```
Internal device: 192.168.1.10
Router public IP: 203.0.113.1
Destination: google.com at 142.250.179.206

Step 1: Device sends packet
        Source: 192.168.1.10:52841 (ephemeral port)
        Destination: 142.250.179.206:443

Step 2: Packet arrives at router (NAT device)
        Router replaces source IP and port:
        Source: 203.0.113.1:54321 (router's public IP, new port)
        Destination: 142.250.179.206:443
        Router stores in NAT table: 54321 ↔ 192.168.1.10:52841

Step 3: Modified packet travels to Google.
        Google sees source as 203.0.113.1:54321
        Google's response goes to 203.0.113.1:54321

Step 4: Response arrives at router
        Router looks up port 54321 in NAT table
        Restores original destination: 192.168.1.10:52841
        Forwards to internal device

Step 5: Internal device receives the response.
        It has no idea NAT happened.
```

### The NAT Table

The router maintains a NAT translation table:

| Internal IP:port | External IP:port | Destination |
|---|---|---|
| 192.168.1.10:52841 | 203.0.113.1:54321 | 142.250.179.206:443 |
| 192.168.1.11:49152 | 203.0.113.1:54322 | 151.101.1.140:80 |
| 192.168.1.10:43000 | 203.0.113.1:54323 | 8.8.8.8:53 |

This is **PAT (Port Address Translation)** — the most common form of NAT, where many internal IPs share one public IP, distinguished by different ports.

```bash
# View NAT/connection tracking table on Linux
sudo conntrack -L
# or
sudo iptables -t nat -L -n -v
```

### Types of NAT

| Type | How it works | Use case |
|---|---|---|
| **Static NAT** | 1 private IP ↔ 1 public IP (permanent) | Server that always needs the same public IP |
| **Dynamic NAT** | Pool of public IPs assigned as needed | Organisations with a block of public IPs |
| **PAT / Overload** | Many private IPs share 1 public IP, separated by ports | Home routers, most enterprise NAT |

### NAT in Cloud Environments

**AWS NAT Gateway:**
- Private subnets (no internet access) use a NAT Gateway to reach the internet for outbound traffic (e.g. downloading packages, calling external APIs).
- Inbound connections cannot be initiated from the internet to private instances — the NAT Gateway doesn't maintain a persistent mapping for unsolicited inbound traffic.
- The NAT Gateway has an Elastic IP (public IP). All private subnet traffic appears to come from this IP.

```
Private EC2 (10.0.2.50) → NAT Gateway (10.0.1.5 private, 52.10.x.x public) → Internet
```

---

# 📓 Chapter 6 — Network Troubleshooting

## 6.1 The Troubleshooting Mindset

**The golden rule:** Troubleshoot **layer by layer, starting from the bottom (Physical) and working up.** Don't suspect a complex Layer 7 application bug before confirming Layer 1 (is it plugged in?), Layer 3 (does routing work?), and Layer 4 (is the port open?).

**The troubleshooting process:**

1. **Define the problem precisely.** "The site is down" is too vague. "HTTP requests to `api.example.com` from the app server timeout after 30 seconds, starting at 14:32 UTC" is actionable.
2. **Gather evidence.** Don't guess. Run commands. Look at logs.
3. **Form a hypothesis.** Based on evidence, what's the most likely cause?
4. **Test the hypothesis.** One test at a time.
5. **Fix, verify, and document.** Confirm the fix works and write down what happened.

## 6.2 Common Network Issues

| Issue | Symptoms | First thing to check |
|---|---|---|
| **Physical/connectivity loss** | No network at all, can't ping anything | Cable, NIC, Wi-Fi, `ip link show` |
| **Routing problem** | Can reach some places but not others | `ip route show`, `traceroute` |
| **DNS failure** | Names don't resolve, but pinging IPs works | `nslookup`, `dig`, `/etc/resolv.conf` |
| **Firewall blocking** | Connection refused or times out | `ss -tuln`, firewall rules, security groups |
| **Wrong IP / subnet** | Can ping same subnet, can't reach other subnets | `ip a`, gateway config |
| **Port not open** | Service not listening | `ss -tuln`, service status |
| **IP address conflict** | Intermittent failures, ARP weirdness | `arp -a`, `ip neigh show` |
| **Slow network** | High latency, low throughput | `ping` RTT, `traceroute` timing, `iperf3` |

## 6.3 Core Diagnostic Commands — In Depth

### `ping` — Test basic connectivity

`ping` sends **ICMP Echo Request** packets and listens for **ICMP Echo Reply.** It tells you if a host is reachable and how long the round trip takes.

```bash
# Basic ping
ping google.com

# Ping with count (stop after 5)
ping -c 5 google.com

# Ping with specific packet size (tests larger packets)
ping -s 1400 google.com

# Ping with interval (every 0.2 seconds)
ping -i 0.2 google.com

# Ping a specific interface
ping -I eth0 google.com

# Flood ping (rapid fire — root required)
sudo ping -f google.com

# Example output:
PING google.com (142.250.179.206): 56 data bytes
64 bytes from 142.250.179.206: icmp_seq=0 ttl=117 time=12.4 ms
64 bytes from 142.250.179.206: icmp_seq=1 ttl=117 time=11.8 ms
64 bytes from 142.250.179.206: icmp_seq=2 ttl=117 time=12.1 ms

# icmp_seq: sequence number (gaps = dropped packets)
# ttl: Time To Live (decrements at each hop — tells you approx distance)
# time: round-trip time in milliseconds
```

**What ping tells you:**

| Result | Meaning |
|---|---|
| Reply received, low RTT | Host is up, connectivity is fine |
| Reply received, high RTT | Host is up but slow — congestion or long route |
| Request timeout | Host is unreachable OR blocking ICMP |
| Unknown host | DNS resolution failed |
| 0% packet loss | Perfect connectivity |
| Packet loss % > 0 | Network instability — congestion or bad link |

> **ICMP is often blocked.** Many firewalls block ping. A timeout doesn't always mean the host is down. If `ping` fails but `nc -zv host 443` succeeds, the host is up — it's just blocking ICMP.

### `traceroute` / `tracert` — Trace the path

`traceroute` shows every router ("hop") between you and the destination. It reveals **where in the path a problem occurs.**

```bash
# Linux/macOS
traceroute google.com
# Windows
tracert google.com

# Use TCP instead of UDP (better through firewalls)
traceroute -T -p 80 google.com

# Use ICMP (like Windows tracert)
traceroute -I google.com

# Example output:
traceroute to google.com (142.250.179.206), 30 hops max
 1  192.168.1.1   (your router)          1.2 ms
 2  10.0.0.1      (ISP gateway)          5.4 ms
 3  72.14.218.2   (ISP backbone)         8.1 ms
 4  209.85.248.1  (Google edge)          10.3 ms
 5  142.250.179.206 (destination)        12.1 ms

# * * * means a router is blocking traceroute probes (not necessarily a problem)
```

**Reading traceroute output:**

- Each line is one hop (one router) along the path.
- Three RTT values per hop (three probes sent).
- A `* * *` line means that router doesn't respond to traceroute probes — not necessarily broken.
- **If latency jumps dramatically at one hop** → the bottleneck is between the previous hop and that one.
- **If all remaining hops after N show * * *** → the problem is AT hop N or its firewall.

### `nslookup` and `dig` — DNS diagnostics

Covered in depth in Chapter 3. Quick reference:

```bash
# Is DNS working at all?
nslookup google.com

# What does my configured resolver return?
dig google.com

# What does the authoritative server say?
dig @ns1.example.com example.com

# Check all resolvers agree (propagation check)
dig @8.8.8.8 example.com +short
dig @1.1.1.1 example.com +short
dig @208.67.222.222 example.com +short

# Reverse lookup (PTR)
dig -x 8.8.8.8
```

### `ss` — Socket Statistics (see what's listening)

`ss` is the modern replacement for `netstat`. Shows active connections, listening ports, and socket state.

```bash
# All listening TCP and UDP sockets with process names
sudo ss -tulnp

# Flags:
# -t = TCP, -u = UDP, -l = listening only, -n = numeric (no DNS), -p = show process

# Example output:
Netid  State   Recv-Q Send-Q  Local Address:Port   Peer Address:Port  Process
tcp    LISTEN  0      128     0.0.0.0:22            0.0.0.0:*         sshd
tcp    LISTEN  0      511     0.0.0.0:80            0.0.0.0:*         nginx
tcp    LISTEN  0      511     0.0.0.0:443           0.0.0.0:*         nginx
tcp    LISTEN  0      128     127.0.0.1:3306        0.0.0.0:*         mysqld

# Show all established connections
ss -tnp

# Show connections to a specific port
ss -tnp | grep :443

# Show socket statistics
ss -s
```

### `netcat (nc)` — The Swiss Army Knife

```bash
# Test if a port is open on a remote host
nc -zv hostname 443
# -z = zero I/O (just check), -v = verbose

# Connect to a service and interact
nc hostname 80
# Then type: GET / HTTP/1.0 [Enter][Enter]

# Listen on a port (useful for testing)
nc -l -p 9999

# Transfer a file
# Receiver:
nc -l -p 9999 > received_file.txt
# Sender:
nc receiver_hostname 9999 < file_to_send.txt

# Port scan a range (diagnostic only on your own systems)
nc -zv hostname 20-100
```

### `curl` — HTTP testing

```bash
# Basic GET request
curl https://example.com

# Show response headers
curl -I https://example.com

# Show both headers and body
curl -v https://example.com

# POST with JSON data
curl -X POST -H "Content-Type: application/json" \
     -d '{"key": "value"}' \
     https://api.example.com/endpoint

# Follow redirects
curl -L http://example.com

# Save to file
curl -o output.html https://example.com

# Show timing breakdown (connect time, TTFB, total)
curl -w "\nConnect: %{time_connect}s\nTTFB: %{time_starttransfer}s\nTotal: %{time_total}s\n" \
     -o /dev/null -s https://example.com

# Specify DNS server (test with different resolver)
curl --dns-servers 8.8.8.8 https://example.com

# Test with a specific IP (bypass DNS)
curl --resolve example.com:443:93.184.216.34 https://example.com
```

### `ip` — Interface and routing management

```bash
# Show all network interfaces and their IPs
ip a
# or: ip addr show

# Show a specific interface
ip a show eth0

# Show routing table
ip route show

# Add a static route
sudo ip route add 10.0.2.0/24 via 192.168.1.1

# Delete a route
sudo ip route del 10.0.2.0/24

# Show neighbour table (ARP cache)
ip neigh show

# Bring an interface up or down
sudo ip link set eth0 up
sudo ip link set eth0 down

# Show link layer info (MAC addresses)
ip link show
```

### `tcpdump` — Capture live traffic

`tcpdump` is a packet analyser. It lets you see exactly what's on the wire — every packet, every header, every byte if you want. Indispensable for deep debugging.

```bash
# Capture all traffic on eth0
sudo tcpdump -i eth0

# Capture on any interface
sudo tcpdump -i any

# Capture specific port
sudo tcpdump -i eth0 port 443

# Capture traffic to/from specific IP
sudo tcpdump -i eth0 host 8.8.8.8

# Capture and show ASCII content (for cleartext protocols)
sudo tcpdump -i eth0 -A port 80

# Save capture to file (open with Wireshark)
sudo tcpdump -i eth0 -w capture.pcap

# Read from file
tcpdump -r capture.pcap

# Don't resolve hostnames (faster, shows IPs)
sudo tcpdump -n -i eth0

# Complex filters
sudo tcpdump -i eth0 'tcp port 80 and host 1.2.3.4'
sudo tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0'  # SYN packets only
```

### `iperf3` — Test bandwidth

```bash
# Install
sudo apt install iperf3

# Server side (run on the machine you're testing to)
iperf3 -s

# Client side (run from the machine you're testing from)
iperf3 -c server_hostname

# UDP test (with target bandwidth)
iperf3 -c server_hostname -u -b 100M

# Reverse test (server sends to client)
iperf3 -c server_hostname -R

# Parallel streams (saturate link)
iperf3 -c server_hostname -P 4
```

## 6.4 The Complete Troubleshooting Playbook

### Scenario 1: "I can't reach the website"

```bash
# Step 1: Can I resolve the hostname?
nslookup example.com
# If no → DNS problem. Check /etc/resolv.conf, check dig @8.8.8.8 example.com

# Step 2: Can I ping the IP? (Skip if you don't know the IP)
ping 93.184.216.34
# Timeout → routing/connectivity problem. Move to step 3.
# Replies → Layer 3 works. Problem is Layer 4 or 7. Move to step 4.

# Step 3: Where does the path break? (if ping fails)
traceroute 93.184.216.34
# Find the last hop that responds — that's where it breaks.

# Step 4: Is the specific port open?
nc -zv 93.184.216.34 443
# Connection refused → server is up but nothing listening on 443 (check the web server)
# Timeout → firewall blocking port 443

# Step 5: Does the service respond?
curl -v https://example.com
# Read the response headers and body for application errors
```

### Scenario 2: "Two of our servers can't talk to each other"

```bash
# On server A:
ip a                     # What IP is server A?
ip route show            # Does A have a route to B's network?
ping SERVER_B_IP         # Can A reach B at all?
traceroute SERVER_B_IP   # Where does the path break?
nc -zv SERVER_B_IP 8080  # Is the port open on B?

# On server B:
ss -tulnp               # Is the service actually listening?
sudo iptables -L -n     # Any firewall rules blocking?
# (Or check AWS Security Groups / NACLs if in cloud)

# Common causes:
# - No route from A's subnet to B's subnet (fix the route table)
# - Firewall/security group blocking the port
# - Service on B isn't listening (check systemctl status)
# - B's service is only listening on 127.0.0.1 (bind address wrong)
```

### Scenario 3: "After deployment, some users see old content"

```bash
# DNS caching/propagation issue
dig +short example.com                # what does your resolver say?
dig @8.8.8.8 +short example.com      # what does Google say?
dig @1.1.1.1 +short example.com      # what does Cloudflare say?
dig example.com | grep -i ttl        # what's the TTL?

# If different resolvers give different answers → propagation in progress
# If all give the new IP but content is old → CDN caching, not DNS
# Check your CDN cache headers:
curl -I https://example.com | grep -i cache
```

### Scenario 4: "Network is slow"

```bash
# Measure latency to various points
ping -c 20 gateway_ip         # latency to your gateway (should be <1ms on LAN)
ping -c 20 8.8.8.8            # latency to internet
ping -c 20 target_server_ip   # latency to your target

# Check for packet loss
ping -c 100 target_server_ip | tail -2

# Trace to find slow hop
traceroute target_server_ip

# Test raw bandwidth
iperf3 -c target_server_ip

# Check interface errors (dropped packets, errors)
ip -s link show eth0
# Look for: errors, dropped, overruns

# Check system-level network stats
cat /proc/net/dev
netstat -s   # protocol statistics
```

### Scenario 5: "The service was working, now it's not — nothing changed"

```bash
# Check if the service is actually running
systemctl status nginx
# or
ps aux | grep nginx

# Check what's on the port
sudo ss -tulnp | grep :80

# Read the service logs
journalctl -u nginx --since "30 minutes ago"
tail -f /var/log/nginx/error.log

# Check disk space (full disk kills services silently)
df -h

# Check memory
free -h

# Check for OOM kills
dmesg | grep -i "oom\|killed"

# Check system resources
top
```

---

# 🎯 Quick-Reference Cheat Sheet

## Addresses

```
IPv4:  192.168.1.100     (32-bit, 4 octets, dotted decimal)
IPv6:  2001:db8::1       (128-bit, hex, colon-separated)
MAC:   00:1A:2B:3C:4D:5E (48-bit, burned into NIC hardware)

Private IP ranges (not routable on internet):
  10.0.0.0/8         (10.x.x.x)
  172.16.0.0/12      (172.16–31.x.x)
  192.168.0.0/16     (192.168.x.x)
  127.0.0.1          = localhost (always your own machine)
```

## Ports

```
22   SSH       443  HTTPS     3306  MySQL
53   DNS       3306 MySQL     5432  PostgreSQL
80   HTTP      5432 Postgres  6379  Redis
```

## OSI Layers (7 → 1)

```
7 Application  — HTTP, SSH, DNS, FTP, SMTP
6 Presentation — TLS, encryption, JPEG
5 Session      — session management, sockets
4 Transport    — TCP, UDP, ports
3 Network      — IP, routing, packets
2 Data Link    — MAC, Ethernet, frames
1 Physical     — cables, Wi-Fi, bits

Memory: "All People Seem To Need Data Processing"
Send = wrap going DOWN. Receive = unwrap going UP.
```

## TCP vs UDP

```
TCP: handshake → reliable → ordered → slower → web, SSH, email, DB
UDP: no setup  → fast     → no order → DNS, streaming, gaming, VPN
```

## DNS

```
Record types:
  A      → domain → IPv4
  AAAA   → domain → IPv6
  CNAME  → domain → another domain (alias)
  MX     → domain → mail server
  TXT    → domain → text (SPF, verification)
  NS     → domain → authoritative nameservers
  PTR    → IP     → domain (reverse)

Resolution: Your resolver → Root → TLD → Authoritative
TTL: how long result is cached (lower = propagates faster)
/etc/hosts: local override, checked BEFORE DNS

Commands:
  dig google.com                  # full DNS query
  dig +short google.com           # just the IP
  dig @8.8.8.8 google.com         # query specific server
  dig +trace google.com           # watch full resolution
  nslookup -type=MX gmail.com     # query MX records
```

## Subnetting

```
CIDR: 192.168.1.0/24
  /24 = 24 network bits, 8 host bits
  Subnet mask: 255.255.255.0
  Hosts: 2^8 − 2 = 254

Block sizes (addresses per subnet):
  /24 = 256    /26 = 64    /28 = 16
  /25 = 128    /27 = 32    /30 = 4

Usable hosts = 2^(host bits) − 2
Bigger prefix = smaller subnet, fewer hosts

NAT: private IP → router → translated to 1 public IP
PAT: many private IPs share 1 public IP via different ports
```

## Troubleshooting Commands

```bash
# Connectivity
ping google.com              # Is it reachable?
ping -c 5 google.com        # 5 pings then stop
traceroute google.com        # Where does the path break?

# DNS
dig +short google.com        # Quick IP lookup
dig @8.8.8.8 google.com      # Ask specific resolver
nslookup -type=MX gmail.com  # MX record
dig -x 8.8.8.8               # Reverse lookup

# Ports / services
ss -tulnp                    # What's listening on this machine?
nc -zv host 443              # Is port 443 open on remote host?
curl -I https://example.com  # HTTP response headers

# Network interfaces
ip a                         # Show interfaces and IPs
ip route show                # Show routing table
ip neigh show                # Show ARP cache

# Capture traffic
sudo tcpdump -i eth0 port 443 -n   # Capture HTTPS traffic
sudo tcpdump -i eth0 host 8.8.8.8  # Traffic to/from 8.8.8.8

# Bandwidth
iperf3 -c server             # Test throughput to server
```

## Routing

```
ip route show                          # view routing table
sudo ip route add 10.2.0.0/24 via GW  # add static route
sudo ip route del 10.2.0.0/24         # remove route

OSPF = inside one organisation (IGP), fast convergence
BGP  = between organisations (EGP), runs the internet
```

---

# 📌 Appendix — What You Must Be Fluent In to Be Hireable

A networking interview or technical review will test these without warning:

1. **Explain what happens when you type `google.com` in a browser.** You must walk through: DNS resolution (resolver → root → TLD → authoritative), TCP handshake to port 443, TLS handshake, HTTP request, response. This single question tests your entire networking knowledge.

2. **Read an `ip a` output** — identify the interface name, IP address, subnet mask, and MAC address.

3. **Read a routing table** (`ip route show`) — explain what each line means and where traffic will go.

4. **Subnet by hand** — given a network like `10.0.0.0/24`, divide it into 4 subnets. State the network address, broadcast address, and usable range of each.

5. **Explain the OSI model** — all 7 layers, what data unit each handles (bit/frame/packet/segment), and which protocols live at each layer.

6. **Distinguish TCP from UDP** — explain the 3-way handshake, when you'd choose each, and name 3 protocols that use each.

7. **Explain what NAT does and why it exists** — including the private IP ranges and how PAT allows many devices to share one public IP.

8. **Diagnose "the website is down"** — you must be able to walk through `nslookup`/`dig`, `ping`, `traceroute`, `nc -zv`, `curl -v`, and `ss -tulnp` in logical order, explaining what each tells you.

9. **DNS records** — explain A, AAAA, CNAME, MX, TXT, NS records and give a use case for each.

10. **TTL and DNS propagation** — explain why a DNS change doesn't take effect immediately, and what you do before a migration to minimise propagation delay.

11. **Ports** — know 22, 53, 80, 443, 3306, 5432 by heart. Explain the difference between well-known ports (0–1023) and ephemeral ports.

12. **`/etc/hosts`** — explain what it is, when it takes precedence over DNS, and give two practical DevOps uses.
