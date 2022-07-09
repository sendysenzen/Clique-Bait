```
CREATE TABLE event_identifier (
  "event_type" INTEGER,
  "event_name" VARCHAR(13));

CREATE TABLE campaign_identifier (
  "campaign_id" INTEGER,
  "products" VARCHAR(3),
  "campaign_name" VARCHAR(40),
  "start_date" TIMESTAMP,
  "end_date" TIMESTAMP);

CREATE TABLE page_hierarchy (
  "page_id" INTEGER,
  "page_name" VARCHAR(14),
  "product_category" VARCHAR(9),
  "product_id" INTEGER);

CREATE TABLE users (
  "user_id" INTEGER,
  "cookie_id" VARCHAR(6),
  "start_date" TIMESTAMP);

CREATE TABLE clique_bait.events (
  "visit_id" VARCHAR(6),
  "cookie_id" VARCHAR(6),
  "page_id" INTEGER,
  "event_type" INTEGER,
  "sequence_number" INTEGER,
  "event_time" TIMESTAMP);

INSERT INTO event_identifier("event_type","event_name")
VALUES 
    ('1', 'Page View'),
    ('2', 'Add to Cart'),
    ('3', 'Purchase'),
    ('4', 'Ad Impression'),
    ('5', 'Ad Click');
    
INSERT INTO campaign_identifier("campaign_id" , "products" , "campaign_name" , "start_date" , "end_date" )
VALUES 
    ('1', '1-3', 'BOGOF - Fishing For Compliments', '1/1/2020  00:00:00', '1/14/2020  00:00:00'),
    ('2', '4-5', '25% Off - Living The Lux Life', '1/15/2020  00:00:00', '1/28/2020  00:00:00'),
    ('3', '6-8', 'Half Off - Treat Your Shellf(ish)', '2/1/2020  00:00:00', '3/31/2020  00:00:00');


INSERT INTO page_hierarchy ("page_id" , "page_name" , "product_category" , "product_id" )
VALUES 
    ('1', 'Home Page', 'null', 'null'),
    ('2', 'All Products', 'null', 'null'),
    ('3', 'Salmon', 'Fish', '1'),
    ('4', 'Kingfish', 'Fish', '2'),
    ('5', 'Tuna', 'Fish', '3'),
    ('6', 'Russian Caviar', 'Luxury', '4'),
    ('7', 'Black Truffle', 'Luxury', '5'),
    ('8', 'Abalone', 'Shellfish', '6'),
    ('9', 'Lobster', 'Shellfish', '7'),
    ('10', 'Crab', 'Shellfish', '8'),
    ('11', 'Oyster', 'Shellfish', '9'),
    ('12', 'Checkout', 'null', 'null'),
    ('13', 'Confirmation', 'null', 'null');

INSERT INTO events ( "visit_id" , "cookie_id" , "page_id" , "event_type" , "sequence_number" , "event_time" )
VALUES
    ('719fd3', '3d83d3', '5', '1', '4', '3/2/2020  00:29:10'),
    ('fb1eb1', 'c5ff25', '5', '2', '8', '1/22/2020  07:59:17'),
    ('23fe81', '1e8c2d', '10', '1', '9', '3/21/2020  13:14:12'),
    ('ad91aa', '648115', '6', '1', '3', '4/27/2020  16:28:10'),
    ('5576d7', 'ac418c', '6', '1', '4', '1/18/2020  04:55:10'),
    ('48308b', 'c686c1', '8', '1', '5', '1/29/2020  06:10:39'),
    ('46b17d', '78f9b3', '7', '1', '12', '2/16/2020  09:45:32'),
    ('9fd196', 'ccf057', '4', '1', '5', '2/14/2020  08:29:13'),
    ('edf853', 'f85454', '1', '1', '1', '2/22/2020  12:59:08'),
    ('3c6716', '02e74f', '3', '2', '5', '1/31/2020  17:56:21');
    
 INSERT INTO users ( "user_id" , "cookie_id" , "start_date" )
 VALUES 
    ('397', '3759ff', '3/30/2020  00:00:00'),
    ('215', '863329', '1/26/2020  00:00:00'),
    ('191', 'eefca9', '3/15/2020  00:00:00'),
    ('89', '764796', '1/7/2020  00:00:00'),
    ('127', '17ccc5', '1/22/2020  00:00:00'),
    ('81', 'b0b666', '3/1/2020  00:00:00'),
    ('260', 'a4f236', '1/8/2020  00:00:00'),
    ('203', 'd1182f', '4/18/2020  00:00:00'),
    ('23', '12dbc8', '1/18/2020  00:00:00'),
    ('375', 'f61d69', '1/3/2020  00:00:00');

```
