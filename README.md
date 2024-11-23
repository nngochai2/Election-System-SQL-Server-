# Election Management System

This project is an **Election Management System** designed to manage elections, voter records, and candidates. It is implemented in **SQL Server** with optimized queries for various tasks. The database structure supports operations like fetching voter details, electoral divisions, candidates, and political parties, as well as efficiently filtering and managing large datasets.

---

## Features

- **Voter Management**: Retrieve voter details and handle filtering operations.
- **Election Events**: Query and manage election-specific data using unique serial numbers.
- **Candidate and Political Party Management**: Fetch candidate details and their associated political parties for specific elections and divisions.
- **Query Optimization**: SQL queries are designed with indexing and performance tuning.
- **Scalability**: Support for large datasets with multiple optimizations.

---

## Database Schema

The project utilizes the following key tables:
1. **VoterRegistry**:
   - Manages voter details (e.g., first name, last name, residential address).
   - Indexed on `voter_id` for faster lookups.

2. **ElectionEvent**:
   - Stores election-specific details like `election_serial_no` and `election_event_id`.
   - Indexed on `election_event_id` and `election_serial_no` for efficient filtering.

3. **ElectoralDivision**:
   - Represents electoral divisions (`division_name`, `electoral_division_id`).
   - Indexed on `electoral_division_id`.

4. **IssuanceRecord**:
   - Tracks issuance records for voters during elections.
   - Indexed on `voter_id` for fast lookups.

5. **Candidate**:
   - Contains details about candidates running for elections.
   - Indexed on `election_event_id` and `political_party_code`.

6. **PoliticalParty**:
   - Stores political party details.
   - Indexed on `party_code`.

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/<your-username>/election-management-system.git
   cd election-management-system
   ```
