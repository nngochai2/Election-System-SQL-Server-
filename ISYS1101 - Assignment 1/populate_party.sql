-- Populate PoliticalParty table with main Australian parties
INSERT INTO PoliticalParty (party_code, party_name, party_logo, party_postal_address, party_secretary, contact_person_name, contact_person_phone, contact_person_email)
VALUES 
('ALP', 'Australian Labor Party', 'alp_logo.png', 'PO Box 6222, Kingston ACT 2604', 'Paul Erickson', 'John Smith', '(02) 6120 0800', 'info@alp.org.au'),
('LPA', 'Liberal Party of Australia', 'lpa_logo.png', 'PO Box 6004, Kingston ACT 2604', 'Andrew Hirst', 'Jane Doe', '(02) 6273 2564', 'info@liberal.org.au'),
('GRN', 'Australian Greens', 'greens_logo.png', 'GPO Box 1108, Canberra ACT 2601', 'Penny Allman-Payne', 'Bob Green', '(02) 6140 3220', 'info@greens.org.au'),
('NAT', 'National Party of Australia', 'nationals_logo.png', 'PO Box 6190, Kingston ACT 2604', 'Ben Hindmarsh', 'Sarah Rural', '(02) 6273 3822', 'info@nationals.org.au'),
('ONP', 'One Nation', 'one_nation_logo.png', 'PO Box 136, Pinkenba QLD 4008', 'James Ashby', 'Peter Patriot', '(07) 3262 1088', 'info@onenation.org.au'),
('UAP', 'United Australia Party', 'uap_logo.png', 'PO Box 837, Canberra ACT 2601', 'Craig Kelly', 'Yellow Palmer', '1800 875 246', 'info@unitedaustraliaparty.org.au')
-- ('IND', 'Independent', 'independent_logo.png', NULL, NULL, NULL, NULL, NULL);