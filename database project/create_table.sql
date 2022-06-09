/* 
WE need 13 tables for this task. The following is the code to create all the tablets.
Affiliate, Partner, Office, Leased_Office, Lease_Holder, Owned_office, Full_Time_Employee, 
Property_Owner, Residential_Property, Ownership_Percentage,Listing, Sale_Listing, Rental_Listing
*/

--Table for Affiliate who will lease/operate the Realtek's office. 
--Leased affiliate operated offices can have one or more affiliates.
--They will be tracked by their ID, Name (First Name, Middle Initial and Last Name) and date of birth (DOB) 
CREATE TABLE Affiliate (
        AffiliateID serial PRIMARY KEY, 
        FirstName varchar(55)NOT NULL,
        MiddleInitial char(1),
        LastName varchar(55)NOT NULL,
        DateofBirth date NOT NULL,
        AffPhone		 char(10),
        AffEmail		 varchar(255)
);  


--Table for Partners who are the realtors
--Each corporately owned/operated office will have one responsible Partner
--They will be tracked by their ID, Name (First Name, Middle Initial and Last Name)
CREATE TABLE Partner
( PartnerID SERIAL PRIMARY KEY, 
  FirstName VARCHAR(55) NOT NULL,
  MiddleInitial CHAR(1),
  LastName VARCHAR(55) NOT NULL,
  ParPhone		 char(10),
  ParEmail		 varchar(255)
);



--Table for Realtek's Office 
--Each office is either owned/operated by them or leased/operated by an affiliate
--They can be tracked by OFfice ID and Address
CREATE TABLE Office(
     OfficeID    SERIAL       PRIMARY KEY,
     Street  varchar(55)   NOT NULL,
     City  varchar(55) NOT NULL,
     Province char(2) NOT NULL,
     PostalCode char(6) NOT NULL,
     IsOwned BOOLEAN NOT NULL,
	 UNIQUE (OfficeID, IsOwned)
);



--Table for Leased Offices with foreign key reference to Office table
--Leased offices will have Lease start and Lease end dates
CREATE TABLE Leased_Office (
     LeaseID   SERIAL UNIQUE NOT NULL,
     LeasedOfficeID INT NOT NULL,
     LeaseStartDate Date NOT Null,
     LeaseEndDate Date Not Null,
     WorkForce Numeric(3),
     IsOwned BOOLEAN NOT NULL CHECK(IsOwned is FALSE),
     CHECK (LeaseEndDate >= LeaseStartDate)
);

--Add Composite Primary Key Constraint for leased_Office table
--It will consist of Leased office ID and Lease ID
ALTER TABLE Leased_Office ADD PRIMARY KEY (LeasedOfficeID,LeaseID);


--Adding the foreign keys to Leased_Office table
--It will be referenced to OfficeID of the Office table
ALTER TABLE Leased_Office
ADD CONSTRAINT FK_Leased_Office
FOREIGN KEY (LeasedOfficeID,IsOwned) REFERENCES Office(OfficeID,IsOwned);


--Table for Lease holders who are the affiliates
--Affiliates can lease more than one office
--These can be tracked by AffiliateID, LeaseID and LeasedOfficeID
CREATE TABLE Lease_Holder (
        AffiliateID integer NOT NULL, 
        LeaseID integer NOT NULL,
        LeasedOfficeID integer NOT NULL);


--Adding the composite primary key constraint for Lease_Holder table
--All three attributes of Lease_Holder table will be used for the composite key 
ALTER TABLE Lease_Holder ADD PRIMARY KEY (AffiliateID,LeaseID, LeasedOfficeID);


--Adding foreign key constraint FK1_Lease_Holder to Lease_Holder table
--It will be referenced to AffiliateID of Affiliate table
ALTER TABLE Lease_Holder
ADD CONSTRAINT FK1_Lease_Holder
FOREIGN KEY (AffiliateID) REFERENCES Affiliate(AffiliateID);

--Adding foreign key constraint FK2_Lease_Holder to Lease_Holder table
--It will be referenced to LeaseID and LeasedOfficeID of Leased_Office table
ALTER TABLE Lease_Holder
ADD CONSTRAINT FK2_Lease_Holder
FOREIGN KEY (LeaseID, LeasedOfficeID) REFERENCES Leased_Office(LeaseID, LeasedOfficeID);


--Table for Realtek's Owned offices
CREATE TABLE Owned_office
(
OwnedOfficeID INT PRIMARY KEY,
PartnerID INT NOT NULL UNIQUE,
ManagerID INT,
IsOwned BOOLEAN NOT NULL CHECK(IsOwned is TRUE)
);


--Table for Full time employees who will work in any of the offices
--Each of them can be tracked using Employee ID and an Employee Name (First Name, Middle Initial and Last Name)
--An employee can only manage the office he/she is currently working in
create table Full_Time_Employee(
EmployeeID      serial  primary key,
FirstName  Varchar(55) not null,
MiddleInitial Char(1),
LastName Varchar(55) not null,
Salary Numeric(8,2) not null check(salary >= 0),
WorkOfficeID int not null,
EmpPhone  char(10),
EmpEmail varchar(255),
UNIQUE (EmployeeID,WorkOfficeID)
);


--Adding foreign key constraint FK1_Owned_Office to Owned_Office table
--It will be referenced to PartnerID of Partner table
ALTER TABLE Owned_Office
ADD CONSTRAINT FK1_Owned_Office
FOREIGN KEY (PartnerID) REFERENCES Partner(PartnerID);

--Adding foreign key constraint FK2_Owned_Office to Owned_Office table
--It will be referenced to EmployeeID and WorkOfficeIDcof Full_Time_Employee table
ALTER TABLE Owned_Office
ADD CONSTRAINT FK2_Owned_Office
FOREIGN KEY (ManagerID,OwnedOfficeID) REFERENCES Full_Time_Employee(EmployeeID,WorkOfficeID);

--Adding foreign key constraint FK3_Owned_Office to Owned_Office table
--It will be referenced to OfficeID and IsOwned of Office table
ALTER TABLE Owned_Office
ADD CONSTRAINT FK3_Owned_Office
FOREIGN KEY (OwnedOfficeID,IsOwned) REFERENCES Office(OfficeID,IsOwned);

--Adding foreign key constraint FK_Full_Time_Employee to Full_Time_Employee table
--It will be referenced to OwnedOfficeID of Owned_Office table
--FOREIGN KEY CONSTRAINT FOR Full_Time_Employee
ALTER TABLE Full_Time_Employee
ADD CONSTRAINT FK_Full_Time_Employee
FOREIGN KEY (WorkOfficeID) REFERENCES Owned_Office(OwnedOfficeID);



--Table for Property Owners
--They can be tracked using Owner ID, Owner Name (First Name, Middle Initial and Last Name) and Owner Address (Street, City, Province and Postal Code)
CREATE TABLE Property_Owner
(
	OwnerID			 serial		 PRIMARY KEY,
	FirstName		 varchar(55)	 NOT NULL,
	MiddleInitial		 char(1),
	LastName			 varchar(55)	 NOT NULL,
	OwnerStreet		 varchar(55)	 NOT NULL,
	OwnerCity		 varchar(55)	 NOT NULL,
	OwnerProvince		 char(2)		 NOT NULL,
	OwnerPostalCode		 char(6)		 NOT NULL,
      	OwnerPhone		 char(10),
	OwnerEmail		 varchar(255)
);

--Table for Resisdential properties for either sale or rent
--Each listed property will have a unique Property ID and Property Address
CREATE TABLE Residential_Property(
  PropertyID SERIAL PRIMARY KEY,
  ListingOfficeID integer NOT NULL,
  Street varchar(55) NOT NULL, 
  City          varchar(55) NOT NULL, 
  Province      char(2) NOT NULL, 
  Postalcode    char(6) NOT NULL
); 

--Table for Ownership percentage 
--Each property will have one or more owners
--In case of mulitple owners, owner's ownership percentage will be tracked
CREATE TABLE Ownership_Percentage 
( 
  PropertyID           integer           NOT NULL, 
  OwnerID            integer           NOT NULL, 
  OwnerPercentage         numeric(5,2)               NOT NULL CHECK (OwnerPercentage > 0 AND OwnerPercentage <= 100), 
  PRIMARY KEY (PropertyID, OwnerID) 
); 

--Adding foreign key constraint FK_Residential_Property to Residential_Property table
--It will be referenced to OfficeID of Office table
ALTER TABLE Residential_Property
ADD CONSTRAINT FK_Residential_Property
FOREIGN KEY (ListingOfficeID) REFERENCES Office(OfficeID);

--Adding foreign key constraint FK1_Ownership_Percentage to Ownership_Percentage table
--It will be referenced to PropertyID of Residential_Property table
ALTER TABLE Ownership_Percentage
ADD CONSTRAINT FK1_Ownership_Percentage
FOREIGN KEY (PropertyID) REFERENCES Residential_Property(PropertyID); 

--Adding foreign key constraint FK2_Ownership_Percentage to Ownership_Percentage table
--It will be referenced to OwnerID of Property_Owner table
ALTER TABLE Ownership_Percentage
ADD CONSTRAINT FK2_Ownership_Percentage
FOREIGN KEY (OwnerID) REFERENCES Property_Owner(OwnerID); 


--Table for Property listings
--Every property will be listed on MLS(multiple listing service)
--They can be tracjed usin unique MLS ID
CREATE TABLE Listing
(
  MLSID             char(8)           PRIMARY KEY,
  PropertyID        integer           NOT NULL,
  Result            varchar(8)        CHECK (Result IN ('Rented','Sold','Delisted',NULL)),
  InactiveDate      date,
  IsSale            boolean           NOT NULL
);

--Adding foreign key constraint FK_Listing to Listing table
--It will be referenced to PropertyID of Residential_Property table
ALTER TABLE Listing 
ADD CONSTRAINT FK_Listing 
FOREIGN KEY (PropertyID) 
REFERENCES Residential_Property (PropertyID);

--Table for properties listed for sales
--Properties for sale will have a sales price,closing duration and commission percentage
CREATE TABLE Sale_Listing
(
  MLSID                  char(8)           PRIMARY KEY,
  SalesPrice             Numeric(13,2)     NOT NULL        CHECK (SalesPrice > 0),
  ClosingDuration        Numeric(4)        NOT NULL        CHECK (ClosingDuration > 0), -- ClosingDuration is in days
  CommissionPercentage   Numeric(5,2)      NOT NULL        CHECK (CommissionPercentage >= 0 AND CommissionPercentage <= 100)
);

--Adding foreign key constraint FK_Sale_Listing to Sale_Listing table
--It will be referenced to MLSID of Listing table
ALTER TABLE Sale_Listing
ADD CONSTRAINT FK_Sale_Listing
FOREIGN KEY (MLSID) 
REFERENCES Listing (MLSID);


--Table for properties listed for rentals
--Rental properties will have monthly rent, rental agreement period and commission amount
CREATE TABLE Rental_Listing
(
  MLSID                      char(8)           PRIMARY KEY,
  MonthlyRent                Numeric(8,2)      NOT NULL        CHECK (MonthlyRent > 0),
  RentalAgreementPeriod      varchar(9)        NOT NULL, 
  CommissionAmount           Numeric(8,2)      NOT NULL        CHECK (CommissionAmount > 0)
);

--Adding foreign key constraint FK_Rental_Listing to Rental_Listing table
--It will be referenced to MLSID of Listing table
ALTER TABLE Rental_Listing
ADD CONSTRAINT FK_Rental_Listing
FOREIGN KEY (MLSID) 
REFERENCES Listing (MLSID);

