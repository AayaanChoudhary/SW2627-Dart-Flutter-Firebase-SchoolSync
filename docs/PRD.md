# SchoolSync — Product Requirements Document (PRD)

## 1. Product Overview

**SchoolSync** is a centralized mobile application designed for school district administrators to monitor and manage important information across multiple schools from a single platform.

The application provides a district-level view of:

* Student attendance
* Fee collections and pending payments
* Examination schedules and progress
* Performance status of individual schools
* District-wide insights

The primary goal of SchoolSync is to reduce fragmented information and give district administrators a simple, centralized dashboard for monitoring the overall status of their schools.

---

# 2. Problem Statement

A school district may manage multiple schools, with each school maintaining separate information related to attendance, fees, and examinations.

This can make it difficult for district administrators to quickly answer questions such as:

* Which schools have low attendance?
* Which schools have pending fee collections?
* Are examinations progressing as planned?
* Which schools require immediate attention?
* What is the overall performance of the district?

SchoolSync solves this problem by bringing this information into one centralized mobile dashboard.

---

# 3. Product Goal

The main goal of SchoolSync is to provide district administrators with a quick and clear overview of the operational status of all schools under their district.

The application should allow administrators to:

1. Monitor district-wide performance.
2. Compare information between schools.
3. Identify schools that require attention.
4. Track attendance trends.
5. Monitor fee collection and pending amounts.
6. Track examination schedules.
7. Identify whether examination activities are **On Track** or **Lagging**.

---

# 4. Target User

## Primary User

### District Administrator

The primary user of SchoolSync is a district-level administrator responsible for monitoring multiple schools.

The administrator can access:

* District Overview
* Attendance Overview
* Fee Overview
* Examination Overview
* Account/Profile

---

# 5. Application Navigation

Based on the provided UI design, SchoolSync will use a **bottom navigation bar** with five primary sections.

| Navigation Item | Page                 |
| --------------- | -------------------- |
| 🏠 Board        | District Overview    |
| ✓ Attendance    | Attendance Overview  |
| ₹ Fees          | Fee Overview         |
| 📅 Exams        | Examination Overview |
| 👤 Profile      | Account              |

The navigation should remain easily accessible throughout the application.

---

# 6. Application Pages

The MVP will contain the following primary pages:

1. **District Overview**
2. **Attendance — District Overview**
3. **Fees — District Overview**
4. **Exams**
5. **Account / Profile**

The application will also require authentication pages:

6. Login
7. Signup
8. Forgot Password

---

# 7. Authentication Module

## 7.1 Login

The Login page allows a district administrator to securely access the SchoolSync application.

### Fields

* Email
* Password

### Actions

* Login
* Forgot Password
* Navigate to Signup

### Expected Behaviour

After successful authentication, the user should be redirected to the **District Overview** page.

---

## 7.2 Signup

The Signup page allows a new administrator account to be created.

### Fields

* Full Name
* Email
* Password
* Confirm Password

### Actions

* Create Account
* Navigate to Login

---

## 7.3 Forgot Password

The Forgot Password page allows users to reset their password.

### Flow

1. User enters their registered email.
2. System sends a password reset request/link.
3. User creates a new password.
4. User logs in using the new password.

---

# 8. District Overview Page

The District Overview acts as the **main home dashboard** of the application.

Based on the provided UI, the page gives administrators a quick summary of the entire district.

## 8.1 Welcome Section

The page displays a personalized greeting.

Example:

> Good morning, Priya

The administrator's initials or profile avatar should also be displayed.

---

## 8.2 Summary Cards

The dashboard contains three main summary cards.

### Attendance

Displays the current district attendance percentage.

Example:

```text
92%
Attendance Today
```

### Fees Collected

Displays the total fee amount collected across the district.

Example:

```text
₹18.4L
Fees Collected
```

### Exams

Displays the number of examinations scheduled during the current week.

Example:

```text
6
Exams This Week
```

---

## 8.3 Pinned Schools

The administrator can view important or selected schools directly on the dashboard.

Each school card should display:

* School Name
* Number of Students
* Attendance Percentage
* Examination Status

### Example

```text
Greenwood Public School

1,240 Students · Attendance 94%

[ ON TRACK ]
```

Another example:

```text
Riverdale High

980 Students · Attendance 88%

[ LAGGING ]
```

---

## 8.4 School Status Indicators

Schools should use clear status indicators.

### On Track

Indicates that the school's examination schedule or progress is proceeding normally.

### Lagging

Indicates that the school requires attention because examination preparation or scheduling is behind.

---

# 9. Attendance — District Overview

The Attendance page provides a school-wise overview of student attendance across the district.

The page title should be:

```text
DISTRICT OVERVIEW

Attendance
```

---

## 9.1 Attendance School Cards

Each school should have an attendance card.

### Information Displayed

* School Name
* Total Number of Students
* Attendance Percentage
* Attendance Progress Bar

### Example

```text
Greenwood Public School

1,240 Students

94%

████████████████
```

---

## 9.2 Attendance Status

Attendance performance can be visually represented using progress indicators.

Suggested status logic:

| Attendance    | Status          |
| ------------- | --------------- |
| 90% and above | Good            |
| 80% – 89%     | Needs Attention |
| Below 80%     | Low Attendance  |

The goal is to allow the district administrator to quickly identify schools with attendance concerns.

---

# 10. Fees — District Overview

The Fees page provides a centralized overview of fee collection across all schools.

The page title should be:

```text
DISTRICT OVERVIEW

Fees
```

---

## 10.1 District Fee Summary

The top of the page displays two main cards.

### Total Collected

Example:

```text
₹18.4L

Collected district-wide
```

### Total Pending

Example:

```text
₹5.6L

Pending district-wide
```

---

## 10.2 School-wise Fee Information

Each school should display:

* School Name
* Amount Collected
* Amount Pending
* Payment Status

### Example

```text
Greenwood Public School

₹6.1L collected · ₹0.9L due

[ CLEARED ]
```

Another example:

```text
Riverdale High

₹3.8L collected · ₹2.1L due

[ DUE ]
```

---

## 10.3 Fee Status

Suggested statuses:

| Condition              | Status  |
| ---------------------- | ------- |
| Low pending amount     | Cleared |
| Pending payment exists | Due     |

This allows administrators to quickly identify schools with outstanding fee collections.

---