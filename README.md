# 🏠 DormTrack: Smart Hostel Issue Management System

**DormTrack** is an integrated ecosystem designed to digitize hostel administration. It replaces fragmented communication with a centralized platform for maintenance, food services, and residential permissions, ensuring a seamless living experience for students and a data-driven management tool for wardens.

---

## 🔐 Core System Architecture

### 1. Authentication & Role-Based Access Control (RBAC)

The system enforces strict data boundaries based on user roles:

* **Student:** Authorized to report issues, apply for leave, view mess menus, and engage with community announcements.
* **Management (Warden/Admin):** Full administrative control including issue assignment, analytics, mess menu updates, and leave approvals.
* **Staff/Caretakers:** View assigned maintenance tasks and update status with remarks.

### 2. Intelligent Issue Reporting

A multi-layered reporting system that captures:

* **Categorization:** Plumbing, Electrical, Wi-Fi, Furniture, etc.
* **Prioritization:** Ranging from Low to Emergency.
* **Privacy Control:** Users can toggle between **Public** (visible to all students to avoid duplicates) and **Private** (visible only to management).
* **Auto-Context:** Automatically tags reports with the student’s Hostel, Block, and Room number from their profile.

### 3. Issue Lifecycle & Workflow

Every reported problem follows a transparent, timestamped journey:
`Reported` → `Assigned` → `In Progress` → `Resolved` → `Closed`

---

## 🍱 Feature Modules

### 🍽️ Digital Mess & Feedback

* **Real-time Menu:** Daily schedules for Breakfast, Lunch, and Dinner with interactive Lottie animations.
* **Quality Analytics:** A star-rating system that allows management to monitor meal satisfaction trends over time.

### 📝 Smart Leave Management

* **Digital Permissions:** Validated workflow for Home Visits, Medical, and Academic leave.
* **Safety Logic:** Automated checks to ensure departure and return dates are logically valid.
* **Parental Contact:** Integrated emergency contact details for every request.

### 🔍 Lost & Found

* A dedicated marketplace for lost items featuring descriptions, photos, and location tags.
* **Claim Workflow:** Moderated process to ensure items are returned to their rightful owners through warden verification.

### 📢 News & Announcements

* Targeted broadcasting for cleaning schedules, pest control, or utility downtime.
* **Granular Targeting:** Send notices to specific blocks or wings rather than the whole hostel.

---

## 📈 Management Analytics Dashboard

The "Command Center" for administration provides high-level insights:

* **Heatmaps:** Identify which blocks have the highest density of issues.
* **Efficiency Metrics:** Tracking average response vs. resolution times.
* **Category Trends:** Data on the most frequent complaints (e.g., "Is the Wi-Fi failing every Tuesday?").

---

## 💡 Value-Added Features

* **Community Interaction:** Threaded comments on public issues allow students to "upvote" or validate recurring problems, highlighting urgency.
* **Duplicate Management:** Admins can merge similar issues into a single resolution thread, keeping the dashboard clean while keeping all original reporters notified.
* **Bento-Style UI:** A modern, card-based interface designed for high readability and "glanceable" information.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **Backend:** Firebase (Firestore, Auth, Storage)
* **Animations:** Lottie
* **State Management:** Provider / Bloc

---

### 📂 Firestore Collection Structure

* `users`: Roles, Room No, Block, Contact.
* `issues`: Type, Status, Priority, Description, Privacy, Timestamps.
* `mess_menu`: Daily food data.
* `leave_requests`: Dates, Reason, Approval Status.
* `announcements`: Scope (Block/Hostel), Content, Date.

---

**DormTrack: Transforming the hostel into a smart-home community.**

---

Would you like me to help you design the **Analytics Dashboard UI** or create the **Firestore Security Rules** that enforce these roles?