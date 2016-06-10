-- phpMyAdmin SQL Dump
-- version 4.2.7.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: May 31, 2016 at 09:46 AM
-- Server version: 5.6.20
-- PHP Version: 5.5.15

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `organism_database`
--

-- --------------------------------------------------------

--
-- Table structure for table `assembly`
--

CREATE TABLE IF NOT EXISTS `assembly` (
`assembly_id` int(11) NOT NULL,
  `species_id` int(11) NOT NULL,
  `n50_val` int(11) NOT NULL,
  `tot_num_contigs` int(11) NOT NULL,
  `contig_length` int(11) NOT NULL,
  `avg_read_len` int(11) NOT NULL,
  `contig_status` char(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `associations`
--

CREATE TABLE IF NOT EXISTS `associations` (
`assoc_id` int(11) NOT NULL,
  `association` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `energy_source`
--

CREATE TABLE IF NOT EXISTS `energy_source` (
`esource_id` int(11) NOT NULL,
  `source_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `energy_source_species`
--

CREATE TABLE IF NOT EXISTS `energy_source_species` (
`ess_id` int(11) NOT NULL,
  `esource_id` int(11) NOT NULL,
  `species_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `genus`
--

CREATE TABLE IF NOT EXISTS `genus` (
  `genus_taxa_id` int(11) NOT NULL,
  `genus_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `links`
--

CREATE TABLE IF NOT EXISTS `links` (
`link_id` int(11) NOT NULL,
  `link` varchar(255) NOT NULL,
  `species_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `locations`
--

CREATE TABLE IF NOT EXISTS `locations` (
`location_id` int(11) NOT NULL,
  `location_name` varchar(150) NOT NULL,
  `location_type_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `location_type`
--

CREATE TABLE IF NOT EXISTS `location_type` (
`type_id` int(11) NOT NULL,
  `type_name` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `media_types`
--

CREATE TABLE IF NOT EXISTS `media_types` (
`media_type_id` int(11) NOT NULL,
  `media_name` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `paper`
--

CREATE TABLE IF NOT EXISTS `paper` (
`paper_id` int(11) NOT NULL,
  `paper_name` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

CREATE TABLE IF NOT EXISTS `projects` (
`project_id` int(11) NOT NULL,
  `project_name` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `samplers`
--

CREATE TABLE IF NOT EXISTS `samplers` (
`sampler_id` int(11) NOT NULL,
  `sampler_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `samples`
--

CREATE TABLE IF NOT EXISTS `samples` (
`sample_id` int(11) NOT NULL,
  `sample_name` varchar(36) NOT NULL,
  `sampler_id` int(11) NOT NULL,
  `collector_id` int(11) NOT NULL,
  `dna_quant_vol_ul` double(5,2) NOT NULL,
  `location_id` int(11) NOT NULL,
  `remarks` text NOT NULL,
  `project_id` int(11) NOT NULL,
  `sample_type` varchar(3) NOT NULL,
  `sampling_height` decimal(8,2) NOT NULL,
  `sampling_start_date` date NOT NULL,
  `sampling_time` time NOT NULL,
  `storage_method` varchar(20) NOT NULL,
  `media_type_id` int(11) NOT NULL,
  `collection_temperature` varchar(4) NOT NULL,
  `pacbio_seq` char(1) NOT NULL,
  `sequencer_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `samples_users`
--

CREATE TABLE IF NOT EXISTS `samples_users` (
`sample_user_id` int(11) NOT NULL,
  `sample_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `sequencer`
--

CREATE TABLE IF NOT EXISTS `sequencer` (
`sequencer_id` int(11) NOT NULL,
  `sequencer_name` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `sequences`
--

CREATE TABLE IF NOT EXISTS `sequences` (
`sequences_id` int(11) NOT NULL,
  `species_id` int(11) NOT NULL,
  `sequence` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `species`
--

CREATE TABLE IF NOT EXISTS `species` (
  `species_strain_taxa_id` int(11) NOT NULL,
  `species_strain_name` varchar(50) NOT NULL,
  `genus_taxa_id` int(11) NOT NULL,
  `genome_availability` char(1) NOT NULL,
  `genome_size` int(11) NOT NULL,
  `genome_size_units` varchar(3) NOT NULL,
  `association_id` int(11) NOT NULL,
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `species_associations`
--

CREATE TABLE IF NOT EXISTS `species_associations` (
`species_association_id` int(11) NOT NULL,
  `species_id` int(11) NOT NULL,
  `association_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `species_paper`
--

CREATE TABLE IF NOT EXISTS `species_paper` (
`species_paper_id` int(11) NOT NULL,
  `species_id` int(11) NOT NULL,
  `paper_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `species_samples`
--

CREATE TABLE IF NOT EXISTS `species_samples` (
`species_sample_id` int(11) NOT NULL,
  `species_id` int(11) NOT NULL,
  `sample_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
`user_id` int(11) NOT NULL,
  `user_name` varchar(30) NOT NULL,
  `password` varchar(20) NOT NULL,
  `role` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `assembly`
--
ALTER TABLE `assembly`
 ADD PRIMARY KEY (`assembly_id`), ADD KEY `species_id` (`species_id`);

--
-- Indexes for table `associations`
--
ALTER TABLE `associations`
 ADD PRIMARY KEY (`assoc_id`), ADD UNIQUE KEY `association` (`association`);

--
-- Indexes for table `energy_source`
--
ALTER TABLE `energy_source`
 ADD PRIMARY KEY (`esource_id`);

--
-- Indexes for table `energy_source_species`
--
ALTER TABLE `energy_source_species`
 ADD PRIMARY KEY (`ess_id`), ADD KEY `esource_id` (`esource_id`), ADD KEY `species_id` (`species_id`);

--
-- Indexes for table `genus`
--
ALTER TABLE `genus`
 ADD PRIMARY KEY (`genus_taxa_id`);

--
-- Indexes for table `links`
--
ALTER TABLE `links`
 ADD PRIMARY KEY (`link_id`), ADD KEY `species_id` (`species_id`);

--
-- Indexes for table `locations`
--
ALTER TABLE `locations`
 ADD PRIMARY KEY (`location_id`), ADD UNIQUE KEY `location_name` (`location_name`), ADD KEY `location_type_id` (`location_type_id`);

--
-- Indexes for table `location_type`
--
ALTER TABLE `location_type`
 ADD PRIMARY KEY (`type_id`);

--
-- Indexes for table `media_types`
--
ALTER TABLE `media_types`
 ADD PRIMARY KEY (`media_type_id`);

--
-- Indexes for table `paper`
--
ALTER TABLE `paper`
 ADD PRIMARY KEY (`paper_id`);

--
-- Indexes for table `projects`
--
ALTER TABLE `projects`
 ADD PRIMARY KEY (`project_id`);

--
-- Indexes for table `samplers`
--
ALTER TABLE `samplers`
 ADD PRIMARY KEY (`sampler_id`), ADD UNIQUE KEY `sampler_name` (`sampler_name`);

--
-- Indexes for table `samples`
--
ALTER TABLE `samples`
 ADD PRIMARY KEY (`sample_id`), ADD UNIQUE KEY `sample_name` (`sample_name`), ADD KEY `sampler_id` (`sampler_id`), ADD KEY `collector_id` (`collector_id`), ADD KEY `location_id` (`location_id`), ADD KEY `project_id` (`project_id`), ADD KEY `media_type_id` (`media_type_id`), ADD KEY `sequencer_id` (`sequencer_id`);

--
-- Indexes for table `samples_users`
--
ALTER TABLE `samples_users`
 ADD PRIMARY KEY (`sample_user_id`), ADD KEY `sample_id` (`sample_id`), ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `sequencer`
--
ALTER TABLE `sequencer`
 ADD PRIMARY KEY (`sequencer_id`);

--
-- Indexes for table `sequences`
--
ALTER TABLE `sequences`
 ADD PRIMARY KEY (`sequences_id`), ADD KEY `species_id` (`species_id`);

--
-- Indexes for table `species`
--
ALTER TABLE `species`
 ADD PRIMARY KEY (`species_strain_taxa_id`), ADD KEY `genus_taxa_id` (`genus_taxa_id`), ADD KEY `association_id` (`association_id`);

--
-- Indexes for table `species_associations`
--
ALTER TABLE `species_associations`
 ADD PRIMARY KEY (`species_association_id`), ADD KEY `species_id` (`species_id`), ADD KEY `association_id` (`association_id`);

--
-- Indexes for table `species_paper`
--
ALTER TABLE `species_paper`
 ADD PRIMARY KEY (`species_paper_id`), ADD KEY `species_id` (`species_id`), ADD KEY `paper_id` (`paper_id`);

--
-- Indexes for table `species_samples`
--
ALTER TABLE `species_samples`
 ADD PRIMARY KEY (`species_sample_id`), ADD KEY `species_id` (`species_id`), ADD KEY `sample_id` (`sample_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
 ADD PRIMARY KEY (`user_id`), ADD UNIQUE KEY `user_name` (`user_name`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `assembly`
--
ALTER TABLE `assembly`
MODIFY `assembly_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `associations`
--
ALTER TABLE `associations`
MODIFY `assoc_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `energy_source`
--
ALTER TABLE `energy_source`
MODIFY `esource_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `energy_source_species`
--
ALTER TABLE `energy_source_species`
MODIFY `ess_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `links`
--
ALTER TABLE `links`
MODIFY `link_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `locations`
--
ALTER TABLE `locations`
MODIFY `location_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `location_type`
--
ALTER TABLE `location_type`
MODIFY `type_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `media_types`
--
ALTER TABLE `media_types`
MODIFY `media_type_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `paper`
--
ALTER TABLE `paper`
MODIFY `paper_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `projects`
--
ALTER TABLE `projects`
MODIFY `project_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `samplers`
--
ALTER TABLE `samplers`
MODIFY `sampler_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `samples`
--
ALTER TABLE `samples`
MODIFY `sample_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `samples_users`
--
ALTER TABLE `samples_users`
MODIFY `sample_user_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `sequencer`
--
ALTER TABLE `sequencer`
MODIFY `sequencer_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `sequences`
--
ALTER TABLE `sequences`
MODIFY `sequences_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `species_associations`
--
ALTER TABLE `species_associations`
MODIFY `species_association_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `species_paper`
--
ALTER TABLE `species_paper`
MODIFY `species_paper_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `species_samples`
--
ALTER TABLE `species_samples`
MODIFY `species_sample_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `assembly`
--
ALTER TABLE `assembly`
ADD CONSTRAINT `assembly_ibfk_1` FOREIGN KEY (`species_id`) REFERENCES `species` (`species_strain_taxa_id`) ON UPDATE CASCADE;

--
-- Constraints for table `energy_source_species`
--
ALTER TABLE `energy_source_species`
ADD CONSTRAINT `energy_source_species_ibfk_1` FOREIGN KEY (`esource_id`) REFERENCES `energy_source` (`esource_id`) ON UPDATE CASCADE,
ADD CONSTRAINT `energy_source_species_ibfk_2` FOREIGN KEY (`species_id`) REFERENCES `species` (`species_strain_taxa_id`) ON UPDATE CASCADE;

--
-- Constraints for table `links`
--
ALTER TABLE `links`
ADD CONSTRAINT `links_ibfk_1` FOREIGN KEY (`species_id`) REFERENCES `species` (`species_strain_taxa_id`) ON UPDATE CASCADE;

--
-- Constraints for table `locations`
--
ALTER TABLE `locations`
ADD CONSTRAINT `locations_ibfk_1` FOREIGN KEY (`location_type_id`) REFERENCES `location_type` (`type_id`) ON UPDATE CASCADE;

--
-- Constraints for table `samples`
--
ALTER TABLE `samples`
ADD CONSTRAINT `samples_ibfk_1` FOREIGN KEY (`sampler_id`) REFERENCES `samplers` (`sampler_id`) ON UPDATE CASCADE,
ADD CONSTRAINT `samples_ibfk_2` FOREIGN KEY (`collector_id`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE,
ADD CONSTRAINT `samples_ibfk_3` FOREIGN KEY (`location_id`) REFERENCES `locations` (`location_id`) ON UPDATE CASCADE,
ADD CONSTRAINT `samples_ibfk_4` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON UPDATE CASCADE,
ADD CONSTRAINT `samples_ibfk_5` FOREIGN KEY (`media_type_id`) REFERENCES `media_types` (`media_type_id`) ON UPDATE CASCADE,
ADD CONSTRAINT `samples_ibfk_6` FOREIGN KEY (`sequencer_id`) REFERENCES `sequencer` (`sequencer_id`) ON UPDATE CASCADE;

--
-- Constraints for table `samples_users`
--
ALTER TABLE `samples_users`
ADD CONSTRAINT `samples_users_ibfk_1` FOREIGN KEY (`sample_id`) REFERENCES `samples` (`sample_id`) ON UPDATE CASCADE,
ADD CONSTRAINT `samples_users_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE;

--
-- Constraints for table `sequences`
--
ALTER TABLE `sequences`
ADD CONSTRAINT `sequences_ibfk_1` FOREIGN KEY (`species_id`) REFERENCES `species` (`species_strain_taxa_id`) ON UPDATE CASCADE;

--
-- Constraints for table `species`
--
ALTER TABLE `species`
ADD CONSTRAINT `species_ibfk_1` FOREIGN KEY (`genus_taxa_id`) REFERENCES `genus` (`genus_taxa_id`) ON UPDATE CASCADE,
ADD CONSTRAINT `species_ibfk_2` FOREIGN KEY (`association_id`) REFERENCES `associations` (`assoc_id`) ON UPDATE CASCADE;

--
-- Constraints for table `species_associations`
--
ALTER TABLE `species_associations`
ADD CONSTRAINT `species_associations_ibfk_1` FOREIGN KEY (`species_id`) REFERENCES `species` (`species_strain_taxa_id`) ON UPDATE CASCADE,
ADD CONSTRAINT `species_associations_ibfk_2` FOREIGN KEY (`association_id`) REFERENCES `associations` (`assoc_id`) ON UPDATE CASCADE;

--
-- Constraints for table `species_paper`
--
ALTER TABLE `species_paper`
ADD CONSTRAINT `species_paper_ibfk_1` FOREIGN KEY (`species_id`) REFERENCES `species` (`species_strain_taxa_id`) ON UPDATE CASCADE,
ADD CONSTRAINT `species_paper_ibfk_2` FOREIGN KEY (`paper_id`) REFERENCES `paper` (`paper_id`) ON UPDATE CASCADE;

--
-- Constraints for table `species_samples`
--
ALTER TABLE `species_samples`
ADD CONSTRAINT `species_samples_ibfk_1` FOREIGN KEY (`species_id`) REFERENCES `species` (`species_strain_taxa_id`) ON UPDATE CASCADE,
ADD CONSTRAINT `species_samples_ibfk_2` FOREIGN KEY (`sample_id`) REFERENCES `samples` (`sample_id`) ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
