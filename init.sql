-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 01, 2026 at 10:44 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `inveniqo`
--

-- --------------------------------------------------------

--
-- Table structure for table `ai_predictions`
--

CREATE TABLE `ai_predictions` (
  `predictionID` int(11) NOT NULL,
  `branchID` varchar(255) NOT NULL,
  `productID` varchar(255) NOT NULL,
  `sku` varchar(255) NOT NULL,
  `stockCurrent` int(11) NOT NULL,
  `dailyVelocity` double NOT NULL,
  `daysLeft` int(11) NOT NULL,
  `recommendedQty` int(11) NOT NULL,
  `statusAction` varchar(255) NOT NULL,
  `badgeColor` varchar(50) NOT NULL,
  `status` varchar(50) DEFAULT 'Pending',
  `computedDate` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ai_predictions`
--

INSERT INTO `ai_predictions` (`predictionID`, `branchID`, `productID`, `sku`, `stockCurrent`, `dailyVelocity`, `daysLeft`, `recommendedQty`, `statusAction`, `badgeColor`, `status`, `computedDate`) VALUES
(1, 'B000000001', 'P1776903381896', 'a2', 10, 0.06666666666666667, 150, 3, 'RESTOCK SEGERA (Kritikal)', '#ef4444', 'Pending', '2026-07-01 09:47:51'),
(2, 'B000000001', 'P1781148125911', 'ss1', 29, 0.03333333333333333, 870, 0, 'Selamat (Stok Stabil)', '#10b981', 'Pending', '2026-07-01 09:47:51'),
(3, 'B000000001', 'P1781148548103', 'c1', 0, 0, 999, 20, 'Restock (Bawah Min Stock)', '#f59e0b', 'Pending', '2026-07-01 09:47:51');

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

CREATE TABLE `audit_log` (
  `logID` int(11) NOT NULL,
  `userID` varchar(50) NOT NULL,
  `username` varchar(100) NOT NULL,
  `action` varchar(100) NOT NULL,
  `details` text NOT NULL,
  `ipAddress` varchar(45) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `branch`
--

CREATE TABLE `branch` (
  `branchID` varchar(10) NOT NULL,
  `branchName` varchar(100) NOT NULL,
  `branchAddress` varchar(255) NOT NULL,
  `companyID` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `branch`
--

INSERT INTO `branch` (`branchID`, `branchName`, `branchAddress`, `companyID`) VALUES
('B000000001', 'hq', 'kuala lumpur', 'C000000001'),
('B000000002', 'selangor', 'petaling jaya', 'C000000001'),
('B000000003', 'pahang', 'kuantan', 'C000000001');

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `categoryID` int(11) NOT NULL,
  `categoryName` varchar(100) NOT NULL,
  `companyID` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`categoryID`, `categoryName`, `companyID`) VALUES
(1, 'shirt', 'C000000001'),
(2, 'pants', 'C000000001'),
(3, 'bag', 'C000000001'),
(5, 'electronic', 'C000000001'),
(6, 'shoes', 'C000000001'),
(7, 'accessories', 'C000000001'),
(8, 'try', 'C000000001');

-- --------------------------------------------------------

--
-- Table structure for table `company`
--

CREATE TABLE `company` (
  `companyID` varchar(10) NOT NULL,
  `companyName` varchar(100) NOT NULL,
  `companyEmail` varchar(100) NOT NULL,
  `businessRegNo` varchar(50) NOT NULL,
  `companyAddress` text DEFAULT NULL,
  `companyLogo` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `company`
--

INSERT INTO `company` (`companyID`, `companyName`, `companyEmail`, `businessRegNo`, `companyAddress`, `companyLogo`) VALUES
('C000000001', 'abc', 'abc@abc.com', '12345678', 'kuala lumpur', 'uploads/company/logo_C000000001_1782899308777.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `productID` varchar(15) NOT NULL,
  `productName` varchar(255) NOT NULL,
  `sku` varchar(50) DEFAULT NULL,
  `categoryID` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `costPrice` decimal(10,2) DEFAULT NULL,
  `sellingPrice` decimal(10,2) DEFAULT NULL,
  `companyID` varchar(10) DEFAULT NULL,
  `productImage` varchar(255) DEFAULT 'uploads/product/defaultproduct.png',
  `status` enum('Pending','Active','Inactive') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`productID`, `productName`, `sku`, `categoryID`, `description`, `costPrice`, `sellingPrice`, `companyID`, `productImage`, `status`) VALUES
('P1776883320140', 't shirt', 'a1', 1, 'shirt', 3.00, 5.00, 'C000000001', 'uploads/product/prod_P1776883320140.jpg', 'Inactive'),
('P1776903381896', 'long pants', 'a2', 2, 'brown', 3.00, 10.00, 'C000000001', 'uploads/product/prod_P1776903381896.jpg', 'Active'),
('P1776904766928', 'bag', 'a3', 3, 'black', 34.00, 50.00, 'C000000001', 'uploads/product/prod_P1776904766928.jpg', 'Inactive'),
('P1779280143485', 'phone', 'as1', 5, 'iphone 13 pro', 1200.00, 1500.00, 'C000000001', 'uploads/product/prod_P1779280143485.jpg', 'Inactive'),
('P1781148125911', 'Sport Shoes', 'ss1', 6, 'kasut sukan', 20.00, 30.00, 'C000000001', 'uploads/product/prod_P1781148125911.jpg', 'Active'),
('P1782934800666', 'bag', 'b1', 3, 'bag', 10.00, 20.00, 'C000000001', 'uploads/product/prod_P1782934800666_1782934800674.jfif', 'Active');

-- --------------------------------------------------------

--
-- Table structure for table `product_branch`
--

CREATE TABLE `product_branch` (
  `pbID` int(11) NOT NULL,
  `productID` varchar(15) NOT NULL,
  `branchID` varchar(10) NOT NULL,
  `quantity` int(11) DEFAULT 0,
  `low_stock_threshold` int(11) DEFAULT 10
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product_branch`
--

INSERT INTO `product_branch` (`pbID`, `productID`, `branchID`, `quantity`, `low_stock_threshold`) VALUES
(1, 'P1776883320140', 'B000000001', 14, 10),
(2, 'P1776903381896', 'B000000001', 10, 10),
(3, 'P1776904766928', 'B000000001', 0, 10),
(6, 'P1779280143485', 'B000000001', 10, 10),
(8, 'P1781148125911', 'B000000001', 0, 10),
(10, 'P1782934800666', 'B000000003', 0, 10);

-- --------------------------------------------------------

--
-- Table structure for table `product_variants`
--

CREATE TABLE `product_variants` (
  `variantID` int(11) NOT NULL,
  `productID` varchar(255) NOT NULL,
  `size` varchar(50) DEFAULT NULL,
  `color` varchar(50) DEFAULT NULL,
  `variant_sku` varchar(255) NOT NULL,
  `stock_qty` int(11) DEFAULT 0,
  `imagePath` varchar(255) DEFAULT NULL,
  `branchID` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product_variants`
--

INSERT INTO `product_variants` (`variantID`, `productID`, `size`, `color`, `variant_sku`, `stock_qty`, `imagePath`, `branchID`) VALUES
(4, 'P1776883320140', 'M', 'BLK', 'BLK1', 5, NULL, ''),
(5, 'P1776883320140', 'S', 'BLK', 'BLK2', 5, NULL, ''),
(6, 'P1776883320140', 'L', 'BLK', 'BLK3', 5, NULL, ''),
(7, 'P1776883320140', 'XL', 'BLK', 'BLK4', 5, NULL, ''),
(8, 'P1779280143485', '128gb', 'blk', 'ip-blk128', 5, NULL, ''),
(9, 'P1779280143485', '256gb', 'blk', 'ip-blk256', 5, NULL, ''),
(12, 'P1776903381896', 's', 'brown', 'sbrown', 6, NULL, ''),
(13, 'P1776903381896', 'm', 'brown', 'mbrown', 4, NULL, ''),
(14, 'P1781148125911', '39', 'blk', 'blk39', 0, '', 'B000000001'),
(15, 'P1781148125911', '40', 'blk', 'blk40', 0, '', 'B000000001');

-- --------------------------------------------------------

--
-- Table structure for table `role`
--

CREATE TABLE `role` (
  `roleID` varchar(5) NOT NULL,
  `roleName` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `role`
--

INSERT INTO `role` (`roleID`, `roleName`) VALUES
('R1', 'Admin'),
('R2', 'Staff'),
('R3', 'Manager');

-- --------------------------------------------------------

--
-- Table structure for table `sales`
--

CREATE TABLE `sales` (
  `saleID` varchar(50) NOT NULL,
  `branchID` varchar(50) NOT NULL,
  `totalAmount` decimal(10,2) NOT NULL,
  `amountPaid` decimal(10,2) NOT NULL,
  `change` decimal(10,2) NOT NULL,
  `soldBy` varchar(50) NOT NULL,
  `saleDate` timestamp NOT NULL DEFAULT current_timestamp(),
  `customerName` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sales`
--

INSERT INTO `sales` (`saleID`, `branchID`, `totalAmount`, `amountPaid`, `change`, `soldBy`, `saleDate`, `customerName`) VALUES
('INV-1780426617', 'B000000001', 5.00, 10.00, 5.00, 'U000000001', '2026-06-02 18:56:57', NULL),
('INV-1780635965', 'B000000001', 5.00, 10.00, 5.00, 'U000000001', '2026-06-05 05:06:05', NULL),
('INV-1780638518', 'B000000001', 1510.00, 1600.00, 90.00, 'U000000001', '2026-06-05 05:48:38', NULL),
('INV-1780668346', 'B000000001', 65.00, 70.00, 5.00, 'U000000001', '2026-06-05 14:05:46', NULL),
('INV-1780822120', 'B000000001', 10.00, 10.00, 0.00, 'U000000001', '2026-06-07 08:48:40', NULL),
('INV-1780823789', 'B000000001', 1500.00, 1500.00, 0.00, 'U000000001', '2026-06-07 09:16:29', NULL),
('INV-1780823997', 'B000000001', 1500.00, 1500.00, 0.00, 'U000000001', '2026-06-07 09:19:57', NULL),
('INV-1780824389', 'B000000001', 1500.00, 1500.00, 0.00, 'U000000001', '2026-06-07 09:26:29', NULL),
('INV-1780825424', 'B000000001', 1500.00, 1500.00, 0.00, 'U000000001', '2026-06-07 09:43:44', NULL),
('INV-1781094463', 'B000000001', 1500.00, 1500.00, 0.00, 'U000000001', '2026-06-10 12:27:43', NULL),
('INV-1781103463', 'B000000001', 1500.00, 1500.00, 0.00, 'U000000001', '2026-06-10 14:57:43', NULL),
('INV-1781138328', 'B000000001', 5.00, 10.00, 5.00, 'U000000001', '2026-06-11 00:38:48', NULL),
('INV-1781143610', 'B000000001', 3000.00, 3000.00, 0.00, 'U000000001', '2026-06-11 02:06:50', NULL),
('INV-1781144369', 'B000000001', 10.00, 10.00, 0.00, 'U000000001', '2026-06-11 02:19:29', NULL),
('INV-1781148824', 'B000000001', 40.00, 50.00, 10.00, 'U000000001', '2026-06-11 03:33:44', NULL),
('INV-1782802009', 'B000000001', 1515.00, 1520.00, 5.00, 'U000000001', '2026-06-30 06:46:49', NULL),
('INV-MAY-001', 'B000000001', 100.00, 100.00, 0.00, 'U000000001', '2026-05-10 02:30:00', NULL),
('INV-MAY-002', 'B000000001', 1500.00, 1500.00, 0.00, 'U000000001', '2026-05-18 06:15:00', NULL),
('INV-MAY-003', 'B000000001', 75.00, 100.00, 25.00, 'U000000001', '2026-05-28 11:45:00', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sales_detail`
--

CREATE TABLE `sales_detail` (
  `sdID` int(11) NOT NULL,
  `saleID` varchar(50) NOT NULL,
  `productID` varchar(50) NOT NULL,
  `quantity` int(11) NOT NULL,
  `pricePerUnit` decimal(10,2) NOT NULL,
  `costPrice` decimal(10,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sales_detail`
--

INSERT INTO `sales_detail` (`sdID`, `saleID`, `productID`, `quantity`, `pricePerUnit`, `costPrice`, `subtotal`) VALUES
(1, 'INV-1780426617', 'P1776883320140', 1, 5.00, 3.00, 5.00),
(2, 'INV-1780635965', 'P1776883320140', 1, 5.00, 3.00, 5.00),
(3, 'INV-1780638518', 'P1776883320140', 2, 5.00, 3.00, 10.00),
(4, 'INV-1780638518', 'P1779280143485', 1, 1500.00, 1200.00, 1500.00),
(5, 'INV-1780668346', 'P1776883320140', 1, 5.00, 3.00, 5.00),
(6, 'INV-1780668346', 'P1776903381896', 1, 10.00, 3.00, 10.00),
(7, 'INV-1780668346', 'P1776904766928', 1, 50.00, 34.00, 50.00),
(8, 'INV-1780822120', 'P1776883320140', 2, 5.00, 3.00, 10.00),
(9, 'INV-1780823789', 'P1779280143485', 1, 1500.00, 1200.00, 1500.00),
(10, 'INV-1780823997', 'P1779280143485', 1, 1500.00, 1200.00, 1500.00),
(11, 'INV-1780824389', 'P1779280143485', 1, 1500.00, 1200.00, 1500.00),
(12, 'INV-1780825424', 'P1779280143485', 1, 1500.00, 1200.00, 1500.00),
(13, 'INV-1781094463', 'P1779280143485', 1, 1500.00, 0.00, 1500.00),
(14, 'INV-1781103463', 'P1779280143485', 1, 1500.00, 0.00, 1500.00),
(15, 'INV-1781138328', 'P1776883320140', 1, 5.00, 3.00, 5.00),
(16, 'INV-1781143610', 'P1779280143485', 2, 1500.00, 1200.00, 3000.00),
(17, 'INV-1781144369', 'P1776883320140', 2, 5.00, 3.00, 10.00),
(18, 'INV-MAY-001', 'P1776883320140', 20, 5.00, 3.00, 100.00),
(19, 'INV-MAY-002', 'P1779280143485', 1, 1500.00, 1200.00, 1500.00),
(20, 'INV-MAY-003', 'P1776883320140', 15, 5.00, 3.00, 75.00),
(21, 'INV-1781148824', 'P1776883320140', 2, 5.00, 3.00, 10.00),
(22, 'INV-1781148824', 'P1781148125911', 1, 30.00, 20.00, 30.00),
(23, 'INV-1782802009', 'P1776883320140', 1, 5.00, 3.00, 5.00),
(24, 'INV-1782802009', 'P1776903381896', 1, 10.00, 3.00, 10.00),
(25, 'INV-1782802009', 'P1779280143485', 1, 1500.00, 1200.00, 1500.00);

-- --------------------------------------------------------

--
-- Table structure for table `security_logs`
--

CREATE TABLE `security_logs` (
  `logID` int(11) NOT NULL,
  `userID` varchar(255) NOT NULL,
  `action` varchar(255) NOT NULL,
  `ipAddress` varchar(255) DEFAULT NULL,
  `logDate` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `security_logs`
--

INSERT INTO `security_logs` (`logID`, `userID`, `action`, `ipAddress`, `logDate`) VALUES
(1, 'U000000001', 'System Initialized AI Forecasting Engine', '127.0.0.1', '2026-07-01 09:47:51'),
(2, 'U000000002', 'Replenishment Threshold updated for Category: Apparel', '192.168.1.100', '2026-07-01 09:47:51'),
(3, 'U000000001', 'Database Security Audit Trail activated', '127.0.0.1', '2026-07-01 09:47:51');

-- --------------------------------------------------------

--
-- Table structure for table `stock_transaction`
--

CREATE TABLE `stock_transaction` (
  `transactionID` int(11) NOT NULL,
  `productID` varchar(15) NOT NULL,
  `userID` varchar(10) NOT NULL,
  `branchID` varchar(10) NOT NULL,
  `transactionType` enum('IN','OUT') NOT NULL,
  `quantity` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `remarks` text DEFAULT NULL,
  `evidencePath` varchar(255) DEFAULT NULL,
  `createdAt` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `stock_transaction`
--

INSERT INTO `stock_transaction` (`transactionID`, `productID`, `userID`, `branchID`, `transactionType`, `quantity`, `reason`, `remarks`, `evidencePath`, `createdAt`) VALUES
(1, 'P1776883320140', 'U000000001', 'B000000001', 'IN', 15, 'Supply Restock', 'restock', 'uploads/evidence/1779292710174_context.png', '2026-05-20 23:58:30'),
(2, 'P1776883320140', 'U000000001', 'B000000001', 'OUT', 1, 'Internal Usage', 'use', 'uploads/evidence/1779292783602_shirt.jpg', '2026-05-20 23:59:43'),
(3, 'P1776903381896', 'U000000001', 'B000000001', 'IN', 5, 'Inventory Adjustment', 'adjust', 'uploads/evidence/1779302970596_pants.jfif', '2026-05-21 02:49:30'),
(4, 'P1776904766928', 'U000000007', 'B000000001', 'IN', 2, 'Customer Return', 'return', 'uploads/evidence/1779304575666_bag.jfif', '2026-05-21 03:16:15'),
(5, 'P1779280143485', 'U000000001', 'B000000001', 'IN', 20, 'Supply Restock', 'restock', 'uploads/evidence/1779331867185_laptop.jpg', '2026-05-21 10:51:07'),
(6, 'P1776903381896', 'U000000001', 'B000000001', 'OUT', 5, 'Internal Usage', 'usage', '', '2026-05-21 10:54:24'),
(7, 'P1776903381896', 'U000000001', 'B000000001', 'IN', 1, 'Supply Restock', 'add', 'uploads/evidence/1780493338729_black case.png', '2026-06-03 21:28:58'),
(8, 'P1776883320140', 'U000000001', 'B000000001', 'OUT', 1, 'Sales (POS)', 'Receipt No: INV-1780668346', NULL, '2026-06-05 22:05:46'),
(9, 'P1776903381896', 'U000000001', 'B000000001', 'OUT', 1, 'Sales (POS)', 'Receipt No: INV-1780668346', NULL, '2026-06-05 22:05:46'),
(10, 'P1776904766928', 'U000000001', 'B000000001', 'OUT', 1, 'Sales (POS)', 'Receipt No: INV-1780668346', NULL, '2026-06-05 22:05:46'),
(11, 'P1776883320140', 'U000000001', 'B000000001', 'OUT', 2, 'Sales (POS)', 'Receipt No: INV-1780822120', 'receipts/INV-1780822120.pdf', '2026-06-07 16:48:40'),
(12, 'P1779280143485', 'U000000001', 'B000000001', 'OUT', 1, 'Sales (POS)', 'Receipt No: INV-1780823789', 'receipts/INV-1780823789.pdf', '2026-06-07 17:16:29'),
(13, 'P1779280143485', 'U000000001', 'B000000001', 'OUT', 1, 'Sales (POS)', 'Receipt No: INV-1780823997', 'receipts/INV-1780823997.pdf', '2026-06-07 17:19:57'),
(14, 'P1779280143485', 'U000000001', 'B000000001', 'OUT', 1, 'Sales (POS)', 'Receipt No: INV-1780824389', 'receipts/INV-1780824389.pdf', '2026-06-07 17:26:29'),
(15, 'P1779280143485', 'U000000001', 'B000000001', 'OUT', 1, 'Sales (POS)', 'Receipt No: INV-1780825424', 'receipts/INV-1780825424.pdf', '2026-06-07 17:43:44'),
(16, 'P1779280143485', 'U000000001', 'B000000001', 'OUT', 1, 'Sales (POS)', 'Receipt No: INV-1781094463', 'receipts/INV-1781094463.pdf', '2026-06-10 20:27:43'),
(17, 'P1779280143485', 'U000000001', 'B000000001', 'OUT', 1, 'Sales (POS)', 'Receipt No: INV-1781103463', 'receipts/INV-1781103463.pdf', '2026-06-10 22:57:43'),
(18, 'P1776883320140', 'U000000001', 'B000000001', 'OUT', 1, 'Sales (POS)', 'Receipt No: INV-1781138328', 'receipts/INV-1781138328.pdf', '2026-06-11 08:38:48'),
(19, 'P1779280143485', 'U000000001', 'B000000001', 'IN', 10, 'Supply Restock (Store Room)', 'restock', 'uploads/evidence/1781143153822_black case.png', '2026-06-11 09:59:13'),
(20, 'P1779280143485', 'U000000001', 'B000000001', 'OUT', 5, 'Damaged (Store Room)', 'damaged', 'uploads/evidence/1781143362596_black case.png', '2026-06-11 10:02:42'),
(21, 'P1779280143485', 'U000000001', 'B000000001', 'IN', 5, 'Supply Restock (On-Display)', 'restock', 'uploads/evidence/1781143574818_black case.png', '2026-06-11 10:06:14'),
(22, 'P1779280143485', 'U000000001', 'B000000001', 'OUT', 2, 'Sales (POS)', 'Receipt No: INV-1781143610', 'receipts/INV-1781143610.pdf', '2026-05-31 10:06:50'),
(23, 'P1776883320140', 'U000000001', 'B000000001', 'OUT', 2, 'Sales (POS)', 'Receipt No: INV-1781144369', 'receipts/INV-1781144369.pdf', '2026-06-21 10:19:29'),
(24, 'P1776904766928', 'U000000001', 'B000000001', 'OUT', 1, 'Damaged (Store Room)', '1', '', '2026-06-11 11:07:05'),
(25, 'P1776903381896', 'U000000001', 'B000000001', 'IN', 12, 'Supply Restock (Store Room)', 'restock', 'uploads/evidence/1781148680024_pants.jfif', '2026-06-11 11:31:20'),
(26, 'P1776903381896', 'U000000001', 'B000000001', 'OUT', 2, 'Damaged (Store Room)', 'damaed', 'uploads/evidence/1781148781505_pants.jfif', '2026-06-11 11:33:01'),
(27, 'P1776883320140', 'U000000001', 'B000000001', 'OUT', 2, 'Sales (POS)', 'Receipt No: INV-1781148824', 'receipts/INV-1781148824.pdf', '2026-06-11 11:33:44'),
(28, 'P1781148125911', 'U000000001', 'B000000001', 'OUT', 1, 'Sales (POS)', 'Receipt No: INV-1781148824', 'receipts/INV-1781148824.pdf', '2026-06-11 11:33:44'),
(29, 'P1776883320140', 'U000000001', 'B000000001', 'OUT', 1, 'Sales (POS)', 'Receipt No: INV-1782802009', 'receipts/INV-1782802009.pdf', '2026-06-30 14:46:49'),
(30, 'P1776903381896', 'U000000001', 'B000000001', 'OUT', 1, 'Sales (POS)', 'Receipt No: INV-1782802009', 'receipts/INV-1782802009.pdf', '2026-06-30 14:46:49'),
(31, 'P1779280143485', 'U000000001', 'B000000001', 'OUT', 1, 'Sales (POS)', 'Receipt No: INV-1782802009', 'receipts/INV-1782802009.pdf', '2026-06-30 14:46:49'),
(32, 'P1779280143485', 'U000000001', 'B000000001', 'IN', 1, 'Supply Restock', 'restock', '', '2026-07-01 01:07:47'),
(33, 'P1776903381896', 'U000000001', 'B000000001', 'IN', 1, 'Supply Restock', 'restock', '', '2026-07-01 01:41:06'),
(34, 'P1776903381896', 'U000000001', 'B000000001', 'IN', 1, 'Supply Restock', 'restock', '', '2026-07-01 01:44:09'),
(35, 'P1776903381896', 'U000000001', 'B000000001', 'IN', 1, 'Inventory Adjustment', 'adjust', '', '2026-07-01 01:46:51'),
(36, 'P1776903381896', 'U000000001', 'B000000001', 'OUT', 1, 'Theft/Missing', 'miss', '', '2026-07-01 01:47:26');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `userID` varchar(10) NOT NULL,
  `userName` varchar(100) NOT NULL,
  `userEmail` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `userStatus` varchar(10) DEFAULT 'Active',
  `branchID` varchar(10) DEFAULT NULL,
  `profileImage` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`userID`, `userName`, `userEmail`, `password`, `userStatus`, `branchID`, `profileImage`) VALUES
('U000000001', 'cut athiraa', 'cut@abc.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Active', 'B000000001', 'uploads/profile_U000000001.jpg'),
('U000000002', 'alia', 'alia@abc.com', 'fef3d83e32b4d981b0c0f75206e891268c6aa8bd8db5a315db7bf24168a4be27', 'Active', 'B000000002', NULL),
('U000000005', 'ameliaaa', 'amelia@abc.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Active', 'B000000003', 'uploads/profile_U000000005.jpg'),
('U000000006', 'farhan', 'farhan@abc.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Active', 'B000000001', NULL),
('U000000007', 'munirah', 'muni@abc.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Active', 'B000000001', NULL),
('U000000008', 'ali', 'ali@gmail.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Inactive', 'B000000003', NULL),
('U000000009', 'amri', 'amri@abc.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Active', 'B000000003', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_role`
--

CREATE TABLE `user_role` (
  `userID` varchar(10) NOT NULL,
  `roleID` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_role`
--

INSERT INTO `user_role` (`userID`, `roleID`) VALUES
('U000000001', 'R1'),
('U000000001', 'R3'),
('U000000002', 'R2'),
('U000000005', 'R1'),
('U000000005', 'R3'),
('U000000006', 'R2'),
('U000000006', 'R3'),
('U000000007', 'R2'),
('U000000008', 'R2'),
('U000000009', 'R3');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `ai_predictions`
--
ALTER TABLE `ai_predictions`
  ADD PRIMARY KEY (`predictionID`);

--
-- Indexes for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`logID`);

--
-- Indexes for table `branch`
--
ALTER TABLE `branch`
  ADD PRIMARY KEY (`branchID`),
  ADD KEY `fk_branch_company` (`companyID`);

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`categoryID`),
  ADD KEY `fk_category_company` (`companyID`);

--
-- Indexes for table `company`
--
ALTER TABLE `company`
  ADD PRIMARY KEY (`companyID`),
  ADD UNIQUE KEY `businessRegNo` (`businessRegNo`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`productID`),
  ADD UNIQUE KEY `sku` (`sku`),
  ADD KEY `categoryID` (`categoryID`);

--
-- Indexes for table `product_branch`
--
ALTER TABLE `product_branch`
  ADD PRIMARY KEY (`pbID`),
  ADD UNIQUE KEY `UNIQUE_PROD_BRANCH` (`productID`,`branchID`),
  ADD KEY `branchID` (`branchID`);

--
-- Indexes for table `product_variants`
--
ALTER TABLE `product_variants`
  ADD PRIMARY KEY (`variantID`),
  ADD UNIQUE KEY `variant_sku` (`variant_sku`),
  ADD UNIQUE KEY `UNIQUE_VARIANT_BRANCH` (`variant_sku`,`branchID`),
  ADD KEY `productID` (`productID`);

--
-- Indexes for table `role`
--
ALTER TABLE `role`
  ADD PRIMARY KEY (`roleID`);

--
-- Indexes for table `sales`
--
ALTER TABLE `sales`
  ADD PRIMARY KEY (`saleID`);

--
-- Indexes for table `sales_detail`
--
ALTER TABLE `sales_detail`
  ADD PRIMARY KEY (`sdID`),
  ADD KEY `saleID` (`saleID`);

--
-- Indexes for table `security_logs`
--
ALTER TABLE `security_logs`
  ADD PRIMARY KEY (`logID`);

--
-- Indexes for table `stock_transaction`
--
ALTER TABLE `stock_transaction`
  ADD PRIMARY KEY (`transactionID`),
  ADD KEY `userID` (`userID`),
  ADD KEY `branchID` (`branchID`),
  ADD KEY `fk_stock_trans_product` (`productID`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`userID`),
  ADD UNIQUE KEY `userEmail` (`userEmail`),
  ADD KEY `fk_user_branch` (`branchID`);

--
-- Indexes for table `user_role`
--
ALTER TABLE `user_role`
  ADD PRIMARY KEY (`userID`,`roleID`),
  ADD KEY `fk_ur_role` (`roleID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `ai_predictions`
--
ALTER TABLE `ai_predictions`
  MODIFY `predictionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `logID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `category`
--
ALTER TABLE `category`
  MODIFY `categoryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `product_branch`
--
ALTER TABLE `product_branch`
  MODIFY `pbID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `product_variants`
--
ALTER TABLE `product_variants`
  MODIFY `variantID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `sales_detail`
--
ALTER TABLE `sales_detail`
  MODIFY `sdID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `security_logs`
--
ALTER TABLE `security_logs`
  MODIFY `logID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `stock_transaction`
--
ALTER TABLE `stock_transaction`
  MODIFY `transactionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `branch`
--
ALTER TABLE `branch`
  ADD CONSTRAINT `fk_branch_company` FOREIGN KEY (`companyID`) REFERENCES `company` (`companyID`) ON DELETE CASCADE;

--
-- Constraints for table `category`
--
ALTER TABLE `category`
  ADD CONSTRAINT `fk_category_company` FOREIGN KEY (`companyID`) REFERENCES `company` (`companyID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `product_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `category` (`categoryID`);

--
-- Constraints for table `product_branch`
--
ALTER TABLE `product_branch`
  ADD CONSTRAINT `product_branch_ibfk_1` FOREIGN KEY (`productID`) REFERENCES `product` (`productID`),
  ADD CONSTRAINT `product_branch_ibfk_2` FOREIGN KEY (`branchID`) REFERENCES `branch` (`branchID`);

--
-- Constraints for table `product_variants`
--
ALTER TABLE `product_variants`
  ADD CONSTRAINT `product_variants_ibfk_1` FOREIGN KEY (`productID`) REFERENCES `product` (`productID`) ON DELETE CASCADE;

--
-- Constraints for table `sales_detail`
--
ALTER TABLE `sales_detail`
  ADD CONSTRAINT `sales_detail_ibfk_1` FOREIGN KEY (`saleID`) REFERENCES `sales` (`saleID`) ON DELETE CASCADE;

--
-- Constraints for table `stock_transaction`
--
ALTER TABLE `stock_transaction`
  ADD CONSTRAINT `fk_stock_trans_product` FOREIGN KEY (`productID`) REFERENCES `product` (`productID`) ON DELETE CASCADE,
  ADD CONSTRAINT `stock_transaction_ibfk_1` FOREIGN KEY (`productID`) REFERENCES `product` (`productID`) ON DELETE CASCADE,
  ADD CONSTRAINT `stock_transaction_ibfk_2` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`),
  ADD CONSTRAINT `stock_transaction_ibfk_3` FOREIGN KEY (`branchID`) REFERENCES `branch` (`branchID`);

--
-- Constraints for table `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `fk_user_branch` FOREIGN KEY (`branchID`) REFERENCES `branch` (`branchID`) ON DELETE SET NULL;

--
-- Constraints for table `user_role`
--
ALTER TABLE `user_role`
  ADD CONSTRAINT `fk_ur_role` FOREIGN KEY (`roleID`) REFERENCES `role` (`roleID`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ur_user` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
