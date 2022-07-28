--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

-- Global to local

local insert = table.insert
local require = require
local tonumber = tonumber
local ipairs = ipairs
local pairs = pairs
local PED = PED
local PLAYER = PLAYER
local NETWORK = NETWORK
local STREAMING = STREAMING
local utils = utils
local entities = entities
local TASK = TASK
local ENTITY = ENTITY

local features = require 'features'
local switch = require 'switch'
local enum = require 'enums'
local weapons = require 'weapons'

local ped = {}

ped.GetPedName = switch()
    :case("u_f_y_danceburl_01", function()
        return "Female Club Dancer"
    end)
    :case("s_m_m_tattoo_01", function()
        return "Tattoo Artist 2"
    end)
    :case("g_m_m_armgoon_01", function()
        return "Armenian Goon"
    end)
    :case("s_m_m_strvend_01", function()
        return "Street Vendor"
    end)
    :case("mp_s_m_armoured_01", function()
        return "Armoured Van Security Male"
    end)
    :case("s_f_y_hooker_01", function()
        return "Hooker"
    end)
    :case("s_m_y_uscg_01", function()
        return "US Coastguard"
    end)
    :case("u_m_y_smugmech_01", function()
        return "Hangar Mechanic"
    end)
    :case("mp_f_deadhooker", function()
        return "Dead Hooker"
    end)
    :case("u_m_m_curtis", function()
        return "Curtis"
    end)
    :case("s_m_m_paramedic_01", function()
        return "Paramedic"
    end)
    :case("a_m_m_rurmeth_01", function()
        return "Rural Meth Addict Male"
    end)
    :case("a_c_sharktiger", function()
        return "Tiger Shark"
    end)
    :case("ig_tomcasino", "csb_tomcasino", function()
        return "Tom Connors"
    end)
    :case("a_c_coyote", function()
        return "Coyote"
    end)
    :case("a_f_y_carclub_01", function()
        return "Car Club Female"
    end)
    :case("u_m_m_partytarget", function()
        return "Party Target"
    end)
    :case("a_c_deer", function()
        return "Deer"
    end)
    :case("a_c_westy", function()
        return "Westie"
    end)
    :case("ig_davenorton", "cs_davenorton", function()
        return "Dave Norton"
    end)
    :case("a_f_y_beach_02", function()
        return "Beach Young Female 2"
    end)
    :case("g_m_m_chigoon_01", function()
        return "Chinese Goon"
    end)
    :case("ig_nigel", "cs_nigel", function()
        return "Nigel"
    end)
    :case("s_m_y_blackops_02", function()
        return "Black Ops Soldier 2"
    end)
    :case("u_m_o_dean", function()
        return "Dean"
    end)
    :case("mp_m_avongoon", function()
        return "Avon Goon"
    end)
    :case("ig_dom", "cs_dom", function()
        return "Dom Beasley"
    end)
    :case("s_m_y_winclean_01", function()
        return "Window Cleaner"
    end)
    :case("a_f_y_indian_01", function()
        return "Indian Young Female"
    end)
    :case("u_f_y_beth", function()
        return "Beth"
    end)
    :case("s_m_y_waretech_01", function()
        return "Warehouse Technician"
    end)
    :case("s_m_y_pestcont_01", function()
        return "Pest Control"
    end)
    :case("ig_orleans", "cs_orleans", function()
        return "Bigfoot"
    end)
    :case("g_f_y_lost_01", function()
        return "The Lost MC Female"
    end)
    :case("u_m_m_jesus_01", function()
        return "Jesus"
    end)
    :case("s_m_y_busboy_01", function()
        return "Busboy"
    end)
    :case("a_m_m_tramp_01", "u_m_o_tramp_01", function()
        return "Tramp Male"
    end)
    :case("u_m_y_baygor", function()
        return "Kifflom Guy"
    end)
    :case("a_f_y_rurmeth_01", function()
        return "Rural Meth Addict Female"
    end)
    :case("ig_sacha", function()
        return "Sacha Yetarian"
    end)
    :case("ig_milton", "cs_milton", function()
        return "Milton McIlroy"
    end)
    :case("a_m_y_juggalo_01", function()
        return "Juggalo Male"
    end)
    :case("u_m_m_griff_01", function()
        return "Griff"
    end)
    :case("ig_mrk", function()
        return "Ferdinand Kerimov (Mr. K)"
    end)
    :case("s_m_m_trucker_01", function()
        return "Trucker Male"
    end)
    :case("s_m_y_xmech_01", "s_m_y_xmech_02_mp", function()
        return "Mechanic"
    end)
    :case("ig_englishdave_02", "csb_englishdave_02", function()
        return "English Dave 2"
    end)
    :case("a_m_y_clubcust_03", function()
        return "Club Customer Male 3"
    end)
    :case("ig_mrs_thornhill", "cs_mrs_thornhill", function()
        return "Mrs. Thornhill"
    end)
    :case("a_m_y_bevhills_01", function()
        return "Beverly Hills Young Male"
    end)
    :case("ig_andreas", "cs_andreas", function()
        return "Andreas Sanchez"
    end)
    :case("a_m_y_stwhi_01", function()
        return "White Street Male"
    end)
    :case("u_m_y_dancelthr_01", function()
        return "Male Club Dancer (Leather)"
    end)
    :case("s_m_y_blackops_01", function()
        return "Black Ops Soldier"
    end)
    :case("s_f_y_cop_01", function()
        return "Cop Female"
    end)
    :case("s_m_m_movspace_01", function()
        return "Movie Astronaut"
    end)
    :case("a_m_y_methhead_01", function()
        return "Meth Addict"
    end)
    :case("u_m_y_chip", function()
        return "Chip"
    end)
    :case("ig_manuel", "cs_manuel", function()
        return "Manuel"
    end)
    :case("ig_karen_daniels", "cs_karen_daniels", function()
        return "Karen Daniels"
    end)
    :case("ig_oldrichguy", function()
        return "Old Rich Guy"
    end)
    :case("mp_f_freemode_01", function()
        return "Freemode Female"
    end)
    :case("ig_benny_02", function()
        return "Benny (Los Santos Tuners)"
    end)
    :case("a_f_y_hipster_03", function()
        return "Hipster Female 3"
    end)
    :case("s_m_y_ranger_01", function()
        return "Ranger Male"
    end)
    :case("s_m_m_bouncer_02", function()
        return "Bouncer 2"
    end)
    :case("a_c_stingray", function()
        return "Stingray"
    end)
    :case("ig_terry", "cs_terry", function()
        return "Terry"
    end)
    :case("s_f_m_maid_01", function()
        return "Maid"
    end)
    :case("csb_prologuedriver", function()
        return "Prologue Driver"
    end)
    :case("ig_pilot", "s_m_y_pilot_01", "s_m_m_pilot_01", function()
        return "Pilot"
    end)
    :case("s_m_m_fiboffice_02", function()
        return "FIB Office Worker 2"
    end)
    :case("s_m_y_ammucity_01", function()
        return "Ammu-Nation City Clerk"
    end)
    :case("ig_natalia", "cs_natalia", function()
        return "Natalia"
    end)
    :case("s_f_y_movprem_01", "cs_movpremf_01", function()
        return "Movie Premiere Female"
    end)
    :case("mp_f_cocaine_01", function()
        return "Biker Cocaine Female"
    end)
    :case("csb_undercover", function()
        return "Undercover Cop"
    end)
    :case("a_m_y_hipster_03", function()
        return "Hipster Male 3"
    end)
    :case("u_m_m_glenstank_01", function()
        return "Glen-Stank Male"
    end)
    :case("csb_bogdan", function()
        return "Bogdan"
    end)
    :case("ig_talina", function()
        return "Talina"
    end)
    :case("ig_russiandrunk", function()
        return "Russian Drunk"
    end)
    :case("a_f_y_business_03", function()
        return "Business Young Female 3"
    end)
    :case("ig_sol", "csb_sol", function()
        return "Soloman"
    end)
    :case("s_f_m_fembarber", function()
        return "Barber Female"
    end)
    :case("u_f_y_poppymich_02", function()
        return "Poppy Mitchell 2"
    end)
    :case("csb_jackhowitzer", function()
        return "Jack Howitzer"
    end)
    :case("u_m_y_fibmugger_01", function()
        return "FIB Mugger"
    end)
    :case("mp_f_cardesign_01", function()
        return "Office Garage Mechanic (Female)"
    end)
    :case("s_f_m_sweatshop_01", function()
        return "Sweatshop Worker"
    end)
    :case("ig_car3guy2", "csb_car3guy2", function()
        return "Car Guy 2"
    end)
    :case("u_m_m_blane", function()
        return "Blane"
    end)
    :case("ig_tracydisanto", "cs_tracydisanto", function()
        return "Tracey De Santa"
    end)
    :case("ig_djsolmanager", function()
        return "Soloman Manager"
    end)
    :case("a_m_m_tranvest_01", function()
        return "Transvestite Male"
    end)
    :case("u_m_y_dancerave_01", function()
        return "Male Club Dancer (Rave)"
    end)
    :case("ig_solomon", "cs_solomon", function()
        return "Solomon Richards"
    end)
    :case("u_m_y_danceburl_01", function()
        return "Male Club Dancer (Burlesque)"
    end)
    :case("a_m_y_cyclist_01", "u_m_y_cyclist_01", function()
        return "Cyclist Male"
    end)
    :case("ig_tonya", "csb_tonya", function()
        return "Tonya"
    end)
    :case("a_m_m_salton_02", function()
        return "Salton Male 2"
    end)
    :case("a_c_humpback", function()
        return "Humpback"
    end)
    :case("a_m_y_motox_02", function()
        return "Motocross Biker 2"
    end)
    :case("a_f_y_golfer_01", function()
        return "Golfer Young Female"
    end)
    :case("ig_kerrymcintosh", function()
        return "Kerry McIntosh"
    end)
    :case("a_c_seagull", function()
        return "Seagull"
    end)
    :case("g_m_y_salvagoon_01", function()
        return "Salvadoran Goon"
    end)
    :case("s_m_y_dwservice_02", function()
        return "DW Airport Worker 2"
    end)
    :case("ig_popov", "csb_popov", function()
        return "Dima Popov"
    end)
    :case("s_m_y_westsec_01", function()
        return "Duggan Secruity"
    end)
    :case("csb_anton", "u_m_y_antonb", function()
        return "Anton Beaudelaire"
    end)
    :case("u_m_m_streetart_01", function()
        return "Street Art Male"
    end)
    :case("g_m_y_famfor_01", function()
        return "Families FOR Male"
    end)
    :case("ig_omega", "cs_omega", function()
        return "Omega"
    end)
    :case("mp_m_weapexp_01", function()
        return "Weapon Exp (Male)"
    end)
    :case("a_f_y_clubcust_03", function()
        return "Club Customer Female 3"
    end)
    :case("ig_djtalignazio", function()
        return "DJ Ignazio"
    end)
    :case("ig_celeb_01", "csb_celeb_01", function()
        return "Celebrity"
    end)
    :case("mp_g_m_pros_01", function()
        return "Pros"
    end)
    :case("cs_gurk", function()
        return "GURK?"
    end)
    :case("u_f_o_eileen", function()
        return "Eileen"
    end)
    :case("ig_englishdave", "csb_englishdave", function()
        return "English Dave"
    end)
    :case("a_f_m_bevhills_01", function()
        return "Beverly Hills Female"
    end)
    :case("s_m_m_armoured_02", function()
        return "Armoured Van Security 2"
    end)
    :case("s_m_m_strpreach_01", function()
        return "Street Preacher"
    end)
    :case("a_f_m_soucentmc_01", function()
        return "South Central MC Female"
    end)
    :case("u_m_y_mani", function()
        return "Mani"
    end)
    :case("u_m_y_gunvend_01", function()
        return "Gun Vendor"
    end)
    :case("ig_isldj_04_e_01", function()
        return "Island Dj 4E"
    end)
    :case("ig_maryann", "cs_maryann", function()
        return "Mary-Ann Quinn"
    end)
    :case("a_m_y_acult_01", function()
        return "Altruist Cult Young Male"
    end)
    :case("a_c_cat_01", function()
        return "Cat"
    end)
    :case("u_f_y_corpse_01", function()
        return "Corpse Young Female"
    end)
    :case("g_m_y_lost_03", function()
        return "The Lost MC Male 3"
    end)
    :case("a_m_m_mexlabor_01", function()
        return "Mexican Labourer"
    end)
    :case("ig_chengsr", "cs_chengsr", function()
        return "Wei Cheng"
    end)
    :case("ig_tanisha", "cs_tanisha", function()
        return "Tanisha"
    end)
    :case("a_f_m_bodybuild_01", function()
        return "Bodybuilder Female"
    end)
    :case("ig_ballasog", "csb_ballasog", function()
        return "Ballas OG"
    end)
    :case("s_m_y_barman_01", function()
        return "Barman"
    end)
    :case("a_f_m_prolhost_01", function()
        return "Prologue Host Female"
    end)
    :case("ig_jay_norris", function()
        return "Jay Norris"
    end)
    :case("ig_trafficwarden", "csb_trafficwarden", function()
        return "Traffic Warden"
    end)
    :case("s_m_y_mime", function()
        return "Mime Artist"
    end)
    :case("a_c_pigeon", function()
        return "Pigeon"
    end)
    :case("u_m_y_paparazzi", function()
        return "Paparazzi Young Male"
    end)
    :case("a_c_sharkhammer", function()
        return "Hammerhead Shark"
    end)
    :case("s_m_m_janitor", "csb_janitor", function()
        return "Janitor"
    end)
    :case("ig_clay", "cs_clay", function()
        return "Clay Simons (The Lost)"
    end)
    :case("ig_mp_agent14", "csb_mp_agent14", function()
        return "Agent 14"
    end)
    :case("u_m_m_fibarchitect", function()
        return "FIB Architect"
    end)
    :case("u_m_y_pogo_01", function()
        return "Pogo the Monkey"
    end)
    :case("s_m_m_lifeinvad_01", function()
        return "Life Invader Male"
    end)
    :case("g_m_y_korlieut_01", function()
        return "Korean Lieutenant"
    end)
    :case("ig_johnnyklebitz", "cs_johnnyklebitz", function()
        return "Johnny Klebitz"
    end)
    :case("mp_f_counterfeit_01", function()
        return "Biker Counterfeit Female"
    end)
    :case("u_m_y_corpse_01", function()
        return "Dead Courier"
    end)
    :case("a_m_y_vinewood_01", function()
        return "Vinewood Male"
    end)
    :case("s_m_y_marine_02", function()
        return "Marine Young 2"
    end)
    :case("a_c_rabbit_01", function()
        return "Rabbit"
    end)
    :case("ig_bestmen", function()
        return "Best Man"
    end)
    :case("g_m_m_chemwork_01", function()
        return "Chemical Plant Worker"
    end)
    :case("u_f_m_casinoshop_01", function()
        return "Casino shop owner"
    end)
    :case("mp_f_stripperlite", function()
        return "Stripper Lite (Female)"
    end)
    :case("a_m_m_hillbilly_01", function()
        return "Hillbilly Male"
    end)
    :case("u_m_m_aldinapoli", function()
        return "Al Di Napoli Male"
    end)
    :case("ig_old_man2", "cs_old_man2", function()
        return "Old Man 2"
    end)
    :case("s_m_m_autoshop_02", function()
        return "Autoshop Worker 2"
    end)
    :case("u_f_o_carol", function()
        return "Carol"
    end)
    :case("ig_mimi", "csb_mimi", function()
        return "Mimi"
    end)
    :case("u_m_y_juggernaut_01", function()
        return "Avon Juggernaut"
    end)
    :case("u_m_y_juggernaut_02", function()
        return "Juggernaut 2"
    end)
    :case("s_m_y_construct_02", function()
        return "construction Worker 2"
    end)
    :case("a_m_y_beach_03", function()
        return "Beach Young Male 3"
    end)
    :case("u_m_m_filmdirector", function()
        return "Movie Director"
    end)
    :case("a_m_y_breakdance_01", function()
        return "Breakdancer Male"
    end)
    :case("s_m_o_busker_01", function()
        return "Busker"
    end)
    :case("u_m_y_caleb", function()
        return "Caleb"
    end)
    :case("u_m_m_spyactor", function()
        return "Spy Actor"
    end)
    :case("mp_f_bennymech_01", function()
        return "Benny Mechanic (Female)"
    end)
    :case("u_f_o_prolhost_01", function()
        return "Prologue Host Old Female"
    end)
    :case("u_m_m_bankman", function()
        return "Bank Manager Male"
    end)
    :case("csb_imran", function()
        return "Imran Shinowa"
    end)
    :case("a_m_m_hillbilly_02", function()
        return "Hillbilly Male 2"
    end)
    :case("ig_screen_writer", "csb_screen_writer", function()
        return "Screenwriter"
    end)
    :case("s_m_y_strvend_01", function()
        return "Street Vendor Young"
    end)
    :case("a_m_o_beach_02", function()
        return "Beach Old Male 2"
    end)
    :case("csb_vagspeak", function()
        return "Vagos Speak"
    end)
    :case("mp_m_shopkeep_01", function()
        return "Shopkeeper (Male)"
    end)
    :case("u_m_y_guido_01", function()
        return "Guido"
    end)
    :case("a_m_y_runner_01", function()
        return "Jogger Male"
    end)
    :case("a_f_y_eastsa_01", function()
        return "East SA Young Female"
    end)
    :case("ig_moodyman_02", "csb_moodyman_02", function()
        return "Moodyman"
    end)
    :case("a_m_y_sunbathe_01", function()
        return "Sunbather Male"
    end)
    :case("s_m_m_armoured_01", function()
        return "Armoured Van Security"
    end)
    :case("a_m_m_tennis_01", function()
        return "Tennis Player Male"
    end)
    :case("a_m_o_beach_01", function()
        return "Beach Old Male"
    end)
    :case("a_f_m_ktown_02", function()
        return "Korean Female 2"
    end)
    :case("s_m_y_airworker", function()
        return "Air Worker Male"
    end)
    :case( "u_m_y_burgerdrug_01", "csb_burgerdrug", function()
        return "Burger Drug Worker"
    end)
    :case("a_c_crow", function()
        return "Crow"
    end)
    :case("mp_f_boatstaff_01", function()
        return "Boat-Staff Female"
    end)
    :case("a_m_o_tramp_01", function()
        return "Tramp Old Male"
    end)
    :case("ig_paige", "csb_paige", function()
        return "Paige Harris"
    end)
    :case("ig_taocheng", "cs_taocheng", function()
        return "Tao Cheng"
    end)
    :case("a_c_poodle", function()
        return "Poodle"
    end)
    :case("u_m_y_imporage", function()
        return "Impotent Rage"
    end)
    :case("ig_paper", "cs_paper", function()
        return "United Paper Man"
    end)
    :case("s_m_y_dockwork_01", function()
        return "Dock Worker"
    end)
    :case("ig_georginacheng", "csb_georginacheng", function()
        return "Georgina Cheng"
    end)
    :case("a_f_m_trampbeac_01", function()
        return "Beach Tramp Female"
    end)
    :case("u_f_y_princess", function()
        return "Princess"
    end)
    :case("a_f_y_bevhills_01", function()
        return "Beverly Hills Young Female"
    end)
    :case("ig_janet", "cs_janet", function()
        return "Janet"
    end)
    :case("ig_stretch", "cs_stretch", function()
        return "Stretch"
    end)
    :case("u_m_m_vince", function()
        return "Vince"
    end)
    :case("a_m_y_vinewood_03", function()
        return "Vinewood Male 3"
    end)
    :case("s_m_y_armymech_01", function()
        return "Army Mechanic"
    end)
    :case("ig_chrisformage", "cs_chrisformage", function()
        return "Cris Formage"
    end)
    :case("csb_oscar", function()
        return "Oscar"
    end)
    :case("s_m_y_garbage", function()
        return "Garbage Worker"
    end)
    :case("s_m_m_ups_02", function()
        return "UPS Driver 2"
    end)
    :case("a_m_y_mexthug_01", function()
        return "Mexican Thug"
    end)
    :case("g_f_y_vagos_01", function()
        return "Vagos Female"
    end)
    :case("a_c_dolphin", function()
        return "Dolphin"
    end)
    :case("hc_driver", function()
        return "Jewel Heist Driver"
    end)
    :case("ig_bride", "csb_bride", function()
        return "Bride"
    end)
    :case("s_f_y_ranger_01", function()
        return "Ranger Female"
    end)
    :case("ig_isldj_02", "csb_isldj_02", function()
        return "Island Dj 2"
    end)
    :case("g_m_y_mexgoon_03", function()
        return "Mexican Goon 3"
    end)
    :case("ig_maude", "csb_maude", function()
        return "Maude"
    end)
    :case("ig_josh", "cs_josh", function()
        return "Josh"
    end)
    :case("u_m_y_sbike", function()
        return "Sports Biker"
    end)
    :case("a_m_o_ktown_01", function()
        return "Korean Old Male"
    end)
    :case("u_f_y_taylor", function()
        return "Taylor"
    end)
    :case("a_f_y_tourist_02", function()
        return "Tourist Young Female 2"
    end)
    :case("ig_tenniscoach", "cs_tenniscoach", function()
        return "Tennis Coach"
    end)
    :case("s_f_y_baywatch_01", function()
        return "Baywatch Female"
    end)
    :case("a_f_y_vinewood_01", function()
        return "Vinewood Female"
    end)
    :case("a_m_m_soucent_01", function()
        return "South Central Male"
    end)
    :case("ig_talmm", "csb_talmm", function()
        return "Tale of Us 2"
    end)
    :case("a_m_y_acult_02", function()
        return "Altruist Cult Young Male 2"
    end)
    :case("cs_bradcadaver", function()
        return "Brad's Cadaver"
    end)
    :case("csb_mweather", function()
        return "Merryweather Merc"
    end)
    :case("s_m_m_ups_01", function()
        return "UPS Driver"
    end)
    :case("ig_molly", "cs_molly", function()
        return "Molly"
    end)
    :case("ig_amandatownley", "cs_amandatownley", function()
        return "Amanda De Santa"
    end)
    :case("ig_barry", "cs_barry", function()
        return "Barry"
    end)
    :case("csb_mrs_r", function()
        return "Mrs. Rackman"
    end)
    :case("ig_joeminuteman", "cs_joeminuteman", function()
        return "Minuteman Joe"
    end)
    :case("u_m_y_zombie_01", function()
        return "Zombie"
    end)
    :case("ig_magenta", "cs_magenta", function()
        return "Magenta"
    end)
    :case("g_m_y_strpunk_01", function()
        return "Street Punk"
    end)
    :case("ig_wade", "cs_wade", function()
        return "Wade"
    end)
    :case("a_m_m_hasjew_01", function()
        return "Hasidic Jew Male"
    end)
    :case("mp_m_cocaine_01", function()
        return "Biker Cocaine Male"
    end)
    :case("u_f_m_casinocash_01", function()
        return "Casino Cashier"
    end)
    :case("ig_roccopelosi", "csb_roccopelosi", function()
        return "Rocco Pelosi"
    end)
    :case("a_f_m_business_02", function()
        return "Business Female 2"
    end)
    :case("a_f_m_downtown_01", function()
        return "Downtown Female"
    end)
    :case("g_m_y_ballaorig_01", function()
        return "Ballas Original Male"
    end)
    :case("mp_f_meth_01", function()
        return "Biker Meth Female"
    end)
    :case("ig_vagspeak", function()
        return "Vagos Funeral Speaker"
    end)
    :case("a_c_fish", function()
        return "Fish"
    end)
    :case("ig_dale", "cs_dale", function()
        return "Dale"
    end)
    :case("u_m_y_babyd", function()
        return "Baby D"
    end)
    :case("s_m_m_chemsec_01", function()
        return "Chemical Plant Security"
    end)
    :case("s_f_y_factory_01", function()
        return "Factory Worker Female"
    end)
    :case("u_m_y_party_01", function()
        return "Partygoer"
    end)
    :case("s_f_y_casino_01", function()
        return "Casino Staff Female"
    end)
    :case("s_m_y_casino_01", function()
        return "Casino Staff"
    end)
    :case("s_m_y_shop_mask", function()
        return "Mask Salesman"
    end)
    :case("csb_drugdealer", function()
        return "Drug Dealer"
    end)
    :case("ig_siemonyetarian", "cs_siemonyetarian", function()
        return "Simeon Yetarian"
    end)
    :case("a_c_panther", function()
        return "Panther"
    end)
    :case("s_m_m_pilot_02", function()
        return "Pilot 2"
    end)
    :case("u_m_m_jewelsec_01", function()
        return "Jeweller Security"
    end)
    :case("a_m_y_soucent_04", function()
        return "South Central Young Male 4"
    end)
    :case("s_m_m_strperf_01", function()
        return "Street Performer"
    end)
    :case("s_m_m_scientist_01", function()
        return "Scientist"
    end)
    :case("mp_m_claude_01", function()
        return "Claude Speed"
    end)
    :case("a_m_y_smartcaspat_01", function()
        return "Formel Casino Guests"
    end)
    :case("s_m_m_fiboffice_01", function()
        return "FIB Office Worker"
    end)
    :case("s_m_y_construct_01", function()
        return "construction Worker"
    end)
    :case("s_m_y_fireman_01", function()
        return "Fireman Male"
    end)
    :case("a_m_m_salton_01", function()
        return "Salton Male"
    end)
    :case("a_c_retriever", function()
        return "Retriever"
    end)
    :case("s_m_m_gardener_01", function()
        return "Gardener"
    end)
    :case("s_f_y_bartender_01", function()
        return "Bartender"
    end)
    :case("ig_taocheng2", "cs_taocheng2", function()
        return "Tao Cheng (Casino)"
    end)
    :case("a_c_rottweiler", function()
        return "Rottweiler"
    end)
    :case("a_m_y_business_01", function()
        return "Business Young Male"
    end)
    :case("a_f_m_beach_01", function()
        return "Beach Female"
    end)
    :case("s_m_y_devinsec_01", function()
        return "Devin's Security"
    end)
    :case("ig_jewelass", "u_f_y_jewelass_01", "cs_jewelass", function()
        return "Jeweller Assistant"
    end)
    :case("csb_customer", function()
        return "Customer"
    end)
    :case("u_m_y_militarybum", function()
        return "Ex-Mil Bum"
    end)
    :case("a_f_y_femaleagent", function()
        return "Female Agent"
    end)
    :case("g_m_y_famca_01", function()
        return "Families CA Male"
    end)
    :case("s_m_y_factory_01", function()
        return "Factory Worker Male"
    end)
    :case("a_m_m_soucent_03", function()
        return "South Central Male 3"
    end)
    :case("ig_abigail", "csb_abigail", function()
        return "Abigail Mathers"
    end)
    :case("a_m_y_bevhills_02", function()
        return "Beverly Hills Young Male 2"
    end)
    :case("s_m_m_gaffer_01", function()
        return "Gaffer"
    end)
    :case("ig_jimmyboston", "cs_jimmyboston", function()
        return "Jimmy Boston"
    end)
    :case("ig_djsoljakob", function()
        return "DJ Jakob"
    end)
    :case("a_m_m_beach_02", function()
        return "Beach Male 2"
    end)
    :case("a_m_o_soucent_03", function()
        return "South Central Old Male 3"
    end)
    :case("g_m_y_azteca_01", function()
        return "Azteca"
    end)
    :case("ig_jio", "csb_jio", function()
        return "Jio"
    end)
    :case("ig_jio_02", "csb_jio_02", function()
        return "Jio 2"
    end)
    :case("ig_tomepsilon", "cs_tomepsilon", function()
        return "Epsilon Tom"
    end)
    :case("s_m_y_swat_01", function()
        return "SWAT"
    end)
    :case("s_m_y_doorman_01", function()
        return "Doorman"
    end)
    :case("s_f_y_scrubs_01", function()
        return "Hospital Scrubs Female"
    end)
    :case("a_f_y_hippie_01", function()
        return "Hippie Female"
    end)
    :case("a_f_y_yoga_01", function()
        return "Yoga Female"
    end)
    :case("a_c_mtlion", function()
        return "Mountain Lion"
    end)
    :case("a_f_y_topless_01", function()
        return "Topless"
    end)
    :case("a_f_o_genstreet_01", function()
        return "General Street Old Female"
    end)
    :case("a_f_m_salton_01", function()
        return "Salton Female"
    end)
    :case("ig_talcc", "csb_talcc", function()
        return "Tale of Us 1"
    end)
    :case("a_f_y_eastsa_02", function()
        return "East SA Young Female 2"
    end)
    :case("a_f_y_fitness_02", function()
        return "Fitness Female 2"
    end)
    :case("a_m_y_clubcust_01", function()
        return "Club Customer Male 1"
    end)
    :case("a_f_y_business_04", function()
        return "Business Young Female 4"
    end)
    :case("ig_stevehains", "cs_stevehains", function()
        return "Steve Haines"
    end)
    :case("ig_helmsmanpavel", "csb_helmsmanpavel", function()
        return "Helmsman Pavel"
    end)
    :case("a_m_y_beach_01", function()
        return "Beach Young Male"
    end)
    :case("a_f_m_soucent_02", function()
        return "South Central Female 2"
    end)
    :case("u_m_m_promourn_01", function()
        return "Prologue Mourner Male"
    end)
    :case("ig_fbisuit_01", "cs_fbisuit_01", function()
        return "FIB Suit"
    end)
    :case("a_f_y_tennis_01", function()
        return "Tennis Player Female"
    end)
    :case("a_m_y_beach_02", function()
        return "Beach Young Male 2"
    end)
    :case("a_f_o_soucent_02", function()
        return "South Central Old Female 2"
    end)
    :case("a_f_y_hipster_04", function()
        return "Hipster Female 4"
    end)
    :case("csb_grove_str_dlr", function()
        return "Grove Street Dealer"
    end)
    :case("s_m_y_dwservice_01", function()
        return "DW Airport Worker"
    end)
    :case("ig_claypain", function()
        return "Clay Jackson (The Pain Giver)"
    end)
    :case("a_f_o_soucent_01", function()
        return "South Central Old Female"
    end)
    :case("hc_gunman", function()
        return "Jewel Heist Gunman"
    end)
    :case("a_f_y_epsilon_01", function()
        return "Epsilon Female"
    end)
    :case("player_two", function()
        return "Trevor"
    end)
    :case("a_m_y_runner_02", function()
        return "Jogger Male 2"
    end)
    :case("mp_m_fibsec_01", "s_m_m_fibsec_01", function()
        return "FIB Security"
    end)
    :case("ig_hao_02", "csb_hao_02", function()
        return "Hao 2"
    end)
    :case("a_f_y_business_02", function()
        return "Business Young Female 2"
    end)
    :case("u_f_y_hotposh_01", function()
        return "Hot Posh Female"
    end)
    :case("a_f_y_hipster_01", function()
        return "Hipster Female"
    end)
    :case("ig_isldj_04_d_01", function()
        return "Island Dj 4D"
    end)
    :case("a_f_y_tourist_01", function()
        return "Tourist Young Female"
    end)
    :case("mp_m_weed_01", function()
        return "Biker Weed Male"
    end)
    :case("ig_wendy", "csb_wendy", function()
        return "Wendy"
    end)
    :case("s_f_y_airhostess_01", function()
        return "Air Hostess"
    end)
    :case("ig_lazlow_2", "cs_lazlow_2", function()
        return "Lazlow 2"
    end)
    :case("a_c_chickenhawk", function()
        return "Hawk"
    end)
    :case("a_f_y_vinewood_03", function()
        return "Vinewood Female 3"
    end)
    :case("mp_m_counterfeit_01", function()
        return "Biker Counterfeit Male"
    end)
    :case("ig_benny", function()
        return "Benny"
    end)
    :case("a_f_y_bevhills_04", function()
        return "Beverly Hills Young Female 4"
    end)
    :case("a_f_y_eastsa_03", function()
        return "East SA Young Female 3"
    end)
    :case("s_m_y_waiter_01", function()
        return "Waiter"
    end)
    :case("s_m_m_fieldworker_01", function()
        return "Field Worker"
    end)
    :case("a_f_m_fatbla_01", function()
        return "Fat Black Female"
    end)
    :case("a_m_y_latino_01", function()
        return "Latino Young Male"
    end)
    :case("s_m_y_baywatch_01", function()
        return "Baywatch Male"
    end)
    :case("s_m_m_mariachi_01", function()
        return "Mariachi"
    end)
    :case("a_f_o_indian_01", function()
        return "Indian Old Female"
    end)
    :case("a_f_m_bevhills_02", function()
        return "Beverly Hills Female 2"
    end)
    :case("a_f_m_ktown_01", function()
        return "Korean Female"
    end)
    :case("a_f_m_tramp_01", function()
        return "Tramp Female"
    end)
    :case("ig_lestercrest_2", "cs_lestercrest_2", function()
        return "Lester Crest (Doomsday Heist)"
    end)
    :case("a_f_m_soucent_01", function()
        return "South Central Female"
    end)
    :case("a_f_m_skidrow_01", function()
        return "Skid Row Female"
    end)
    :case("a_f_y_scdressy_01", function()
        return "Dressy Female"
    end)
    :case("ig_lifeinvad_01", "cs_lifeinvad_01", function()
        return "Life Invader"
    end)
    :case("a_m_y_yoga_01", function()
        return "Yoga Male"
    end)
    :case("a_f_y_bevhills_02", function()
        return "Beverly Hills Young Female 2"
    end)
    :case("u_m_o_taphillbilly", function()
        return "Jesco White (Tapdancing Hillbilly)"
    end)
    :case("g_m_y_salvagoon_02", function()
        return "Salvadoran Goon 2"
    end)
    :case("a_f_m_tourist_01", function()
        return "Tourist Female"
    end)
    :case("ig_ramp_hic", "csb_ramp_hic", function()
        return "Hick"
    end)
    :case("mp_m_bogdangoon", function()
        return "Bogdan Goon"
    end)
    :case("a_f_y_vinewood_02", function()
        return "Vinewood Female 2"
    end)
    :case("a_f_m_eastsa_02", function()
        return "East SA Female 2"
    end)
    :case("ig_thornton", "csb_thornton", function()
        return "Thornton Duggan"
    end)
    :case("ig_sessanta", function()
        return "Sessanta"
    end)
    :case("g_m_y_pologoon_01", function()
        return "Polynesian Goon"
    end)
    :case("a_f_y_clubcust_01", function()
        return "Club Customer Female 1"
    end)
    :case("a_f_y_hiker_01", function()
        return "Hiker Female"
    end)
    :case("a_f_m_fatcult_01", function()
        return "Fat Cult Female"
    end)
    :case("a_f_y_soucent_01", function()
        return "South Central Young Female"
    end)
    :case("u_m_m_jewelthief", function()
        return "Jewel Thief"
    end)
    :case("a_f_y_genhot_01", function()
        return "General Hot Young Female"
    end)
    :case("s_m_m_autoshop_03", function()
        return "Autoshop Worker 3"
    end)
    :case("a_f_y_clubcust_04", function()
        return "Club Customer Female 4"
    end)
    :case("a_m_y_ktown_02", function()
        return "Korean Young Male 2"
    end)
    :case("a_f_y_hipster_02", function()
        return "Hipster Female 2"
    end)
    :case("a_m_y_epsilon_01", function()
        return "Epsilon Male"
    end)
    :case("csb_fos_rep", function()
        return "FOS Rep?"
    end)
    :case("csb_hugh", function()
        return "Hugh Welsh"
    end)
    :case("a_f_y_fitness_01", function()
        return "Fitness Female"
    end)
    :case("a_f_m_fatwhite_01", function()
        return "Fat White Female"
    end)
    :case("ig_groom", "csb_groom", function()
        return "Groom"
    end)
    :case("a_f_m_eastsa_01", function()
        return "East SA Female"
    end)
    :case("g_m_m_slasher_01", function()
        return "Gang Slasher Male"
    end)
    :case("u_f_y_corpse_02", function()
        return "Corpse Young Female 2"
    end)
    :case("a_c_chop", "a_c_chop_02", function()
        return "Chop"
    end)
    :case("a_f_y_soucent_02", function()
        return "South Central Young Female 2"
    end)
    :case("a_f_y_juggalo_01", function()
        return "Juggalo Female"
    end)
    :case("a_f_y_skater_01", function()
        return "Skater Female"
    end)
    :case("ig_isldj_00", "csb_isldj_00", function()
        return "Island Dj"
    end)
    :case("s_m_y_prisoner_01", "u_m_y_prisoner_01", function()
        return "Prisoner"
    end)
    :case("a_f_y_business_01", function()
        return "Business Young Female"
    end)
    :case("a_f_o_salton_01", function()
        return "Salton Old Female"
    end)
    :case("csb_alan", function()
        return "Alan Jerome"
    end)
    :case("ig_zimbor", "cs_zimbor", function()
        return "Zimbor"
    end)
    :case("ig_rashcosvki", "csb_rashcosvki", function()
        return "Maxim Rashkovsky"
    end)
    :case("csb_sessanta", function()
        return "sessanta"
    end)
    :case("ig_lestercrest_3", "cs_lestercrest_3", function()
        return "Lester Crest 3"
    end)
    :case("g_m_m_chicold_01", function()
        return "Chinese Goon Older"
    end)
    :case("a_m_y_hasjew_01", function()
        return "Hasidic Jew Young Male"
    end)
    :case("a_m_y_carclub_01", function()
        return "Car Club Male"
    end)
    :case("a_m_m_stlat_02", function()
        return "Latino Street Male 2"
    end)
    :case("s_m_y_marine_03", function()
        return "Marine Young 3"
    end)
    :case("a_c_rat", function()
        return "Rat"
    end)
    :case("ig_djblamadon", "csb_djblamadon", function()
        return "DJ Black Madonna"
    end)
    :case("s_f_y_shop_low", function()
        return "Sales Assistant (Low-End)"
    end)
    :case("ig_marnie", "cs_marnie", function()
        return "Marnie Allen"
    end)
    :case("a_m_y_gencaspat_01", function()
        return "Casual Casino Guests"
    end)
    :case("a_m_y_clubcust_02", function()
        return "Club Customer Male 2"
    end)
    :case("s_m_m_autoshop_01", function()
        return "Autoshop Worker"
    end)
    :case("s_m_m_security_01", function()
        return "Security Guard"
    end)
    :case("a_m_y_gay_01", function()
        return "Gay Male"
    end)
    :case("hc_hacker", function()
        return "Jewel Heist Hacker"
    end)
    :case("s_m_y_clown_01", function()
        return "Clown"
    end)
    :case("mp_m_g_vagfun_01", function()
        return "Vagos Funeral"
    end)
    :case("ig_denise", "cs_denise", function()
        return "Denise"
    end)
    :case("u_m_y_ushi", function()
        return "Ushi"
    end)
    :case("u_m_y_croupthief_01", function()
        return "Casino Thief"
    end)
    :case("a_m_m_skidrow_01", function()
        return "Skid Row Male"
    end)
    :case("s_f_y_sheriff_01", function()
        return "Sheriff Female"
    end)
    :case("a_m_o_salton_01", function()
        return "Salton Old Male"
    end)
    :case("ig_taostranslator2", "cs_taostranslator2", function()
        return "Tao's Translator (Casino)"
    end)
    :case("a_m_y_eastsa_02", function()
        return "East SA Young Male 2"
    end)
    :case("a_m_m_ktown_01", function()
        return "Korean Male"
    end)
    :case("a_m_m_soucent_02", function()
        return "South Central Male 2"
    end)
    :case("a_m_m_soucent_04", function()
        return "South Central Male 4"
    end)
    :case("ig_isldj_01", "csb_isldj_01", function()
        return "Island Dj 1"
    end)
    :case("a_m_y_stlat_01", function()
        return "Latino Street Young Male"
    end)
    :case("s_m_m_postal_02", function()
        return "Postal Worker Male 2"
    end)
    :case("ig_michelle", "cs_michelle", function()
        return "Michelle"
    end)
    :case("ig_juanstrickler", "csb_juanstrickler", function()
        return "Juan Strickler"
    end)
    :case("a_m_o_soucent_01", function()
        return "South Central Old Male"
    end)
    :case("g_m_y_mexgoon_02", function()
        return "Mexican Goon 2"
    end)
    :case("a_m_o_acult_01", function()
        return "Altruist Cult Old Male"
    end)
    :case("a_c_husky", function()
        return "Husky"
    end)
    :case("a_m_m_og_boss_01", function()
        return "OG Boss"
    end)
    :case("a_m_y_soucent_01", function()
        return "South Central Young Male"
    end)
    :case("g_m_importexport_01", function()
        return "Gang Male (Import-Export)"
    end)
    :case("a_m_m_bevhills_02", function()
        return "Beverly Hills Male 2"
    end)
    :case("a_c_cow", function()
        return "Cow"
    end)
    :case("a_m_y_business_02", function()
        return "Business Young Male 2"
    end)
    :case("a_m_y_beachvesp_01", function()
        return "Vespucci Beach Male"
    end)
    :case("a_m_m_genfat_02", function()
        return "General Fat Male 2"
    end)
    :case("cs_tom", function()
        return "Tom"
    end)
    :case("a_m_m_genfat_01", function()
        return "General Fat Male"
    end)
    :case("a_m_y_downtown_01", function()
        return "Downtown Male"
    end)
    :case("a_m_y_beachvesp_02", function()
        return "Vespucci Beach Male 2"
    end)
    :case("a_m_m_malibu_01", function()
        return "Malibu Male"
    end)
    :case("ig_nervousron", "cs_nervousron", function()
        return "Nervous Ron"
    end)
    :case("g_m_y_ballaeast_01", function()
        return "Ballas East Male"
    end)
    :case("a_c_rhesus", function()
        return "Rhesus"
    end)
    :case("a_m_m_acult_01", function()
        return "Altruist Cult Mid-Age Male"
    end)
    :case("a_m_y_jetski_01", function()
        return "Jetskier"
    end)
    :case("a_m_y_vinewood_02", function()
        return "Vinewood Male 2"
    end)
    :case("ig_car3guy1", function()
        return "Car 3 Guy 1"
    end)
    :case("a_m_y_stwhi_02", function()
        return "White Street Male 2"
    end)
    :case("a_c_chimp", function()
        return "Chimp"
    end)
    :case("ig_mrsphillips", "cs_mrsphillips", function()
        return "Mrs. Phillips"
    end)
    :case("ig_drfriedlander", "cs_drfriedlander", function()
        return "Dr. Friedlander"
    end)
    :case("a_m_y_genstreet_01", function()
        return "General Street Young Male"
    end)
    :case("s_f_y_hooker_02", function()
        return "Hooker 2"
    end)
    :case("a_m_y_skater_02", function()
        return "Skater Young Male 2"
    end)
    :case("a_m_m_afriamer_01", function()
        return "African American Male"
    end)
    :case("csb_cop", function()
        return "Cop"
    end)
    :case("ig_vincent_3", function()
         return "Vincent (Casino) 3"
    end)
    :case("ig_vincent_2", "csb_vincent_2", function()
        return "Vincent (Casino) 2"
    end)
    :case("ig_djblamrupert", function()
        return "DJ Rupert"
    end)
    :case("a_c_pug", function()
        return "Pug"
    end)
    :case("a_m_y_eastsa_01", function()
        return "East SA Young Male"
    end)
    :case("a_m_y_tattoocust_01", function()
        return "Tattoo Cust Male"
    end)
    :case("u_m_m_edtoh", function()
        return "Ed Toh"
    end)
    :case("ig_dreyfuss", "cs_dreyfuss", function()
        return "Peter Dreyfuss"
    end)
    :case("ig_ary", "csb_ary", function()
        return "Ary"
    end)
    :case("ig_ary_02", "csb_ary_02", function()
        return "Ary 2"
    end)
    :case("csb_avischwartzman_02", function()
        return "Avi Schwartzman"
    end)
    :case("a_m_m_salton_04", function()
        return "Salton Male 4"
    end)
    :case("mp_f_weed_01", function()
        return "Biker Weed Female"
    end)
    :case("a_m_y_clubcust_04", function()
        return "Club Customer Male 4"
    end)
    :case("mp_m_securoguard_01", function()
        return "Securoserve Guard (Male)"
    end)
    :case("a_m_m_paparazzi_01", function()
        return "Paparazzi Male"
    end)
    :case("a_m_m_trampbeac_01", function()
        return "Beach Tramp Male"
    end)
    :case("a_m_y_stbla_01", function()
        return "Black Street Male"
    end)
    :case("a_m_m_indian_01", function()
        return "Indian Male"
    end)
    :case("g_m_m_korboss_01", function()
        return "Korean Boss"
    end)
    :case("a_m_y_soucent_03", function()
        return "South Central Young Male 3"
    end)
    :case("ig_beverly", "cs_beverly", function()
        return "Beverly Felton"
    end)
    :case("a_c_shepherd", function()
        return "Australian Shepherd"
    end)
    :case("a_m_m_mexcntry_01", function()
        return "Mexican Rural"
    end)
    :case("a_m_y_polynesian_01", function()
        return "Polynesian Young"
    end)
    :case("a_m_m_eastsa_01", function()
        return "East SA Male"
    end)
    :case("u_f_y_spyactress", function()
        return "Spy Actress"
    end)
    :case("a_m_o_soucent_02", function()
        return "South Central Old Male 2"
    end)
    :case("a_m_y_salton_01", function()
        return "Salton Young Male"
    end)
    :case("a_m_y_indian_01", function()
        return "Indian Young Male"
    end)
    :case("a_m_y_beach_04", function()
        return "Beach Young Male 4"
    end)
    :case("s_m_m_movprem_01", "cs_movpremmale", function()
        return "Movie Premiere Male"
    end)
    :case("a_m_y_hipster_01", function()
        return "Hipster Male"
    end)
    :case("s_f_y_hooker_03", function()
        return "Hooker 3"
    end)
    :case("ig_tylerdix", function()
        return "Tyler Dixon"
    end)
    :case("a_m_m_business_01", function()
        return "Business Male"
    end)
    :case("s_m_m_highsec_02", function()
        return "High Security 2"
    end)
    :case("ig_isldj_04_d_02", function()
        return "Island Dj 4D2"
    end)
    :case("csb_prolsec", "u_m_m_prolsec_01", function()
        return "Prologue Security"
    end)
    :case("u_m_y_proldriver_01", function()
        return "Prologue Driver"
    end)
    :case("a_m_y_epsilon_02", function()
        return "Epsilon Male 2"
    end)
    :case("a_f_o_ktown_01", function()
        return "Korean Old Female"
    end)
    :case("u_m_m_doa_01", function()
        return "DOA Man"
    end)
    :case("a_m_y_golfer_01", function()
        return "Golfer Young Male"
    end)
    :case("a_m_o_acult_02", function()
        return "Altruist Cult Old Male 2"
    end)
    :case("s_m_y_prismuscl_01", function()
        return "Prisoner (Muscular)"
    end)
    :case("a_f_y_bevhills_05", function()
        return "Beverly Hills Young Female 5"
    end)
    :case("ig_jimmydisanto2", "cs_jimmydisanto2", function()
        return "Jimmy De Santa 2"
    end)
    :case("a_m_m_beach_01", function()
        return "Beach Male"
    end)
    :case("a_m_m_fatlatin_01", function()
        return "Fat Latino Male"
    end)
    :case("a_m_y_motox_01", function()
        return "Motocross Biker"
    end)
    :case("ig_djtalaurelia", function()
        return " DJ Aurelia"
    end)
    :case("u_f_m_debbie_01", function()
        return "Debbie (AgathaÂ´s Secretary)"
    end)
    :case("a_m_y_skater_01", function()
        return "Skater Young Male"
    end)
    :case("a_m_y_soucent_02", function()
        return "South Central Young Male 2"
    end)
    :case("s_m_m_linecook", function()
        return "Line Cook"
    end)
    :case("ig_agent", "csb_agent", "ig_agent_02", function()
        return "Agent"
    end)
    :case("ig_chef", "s_m_y_chef_01", "csb_chef", function()
        return "Chef"
    end)
    :case("ig_chef2", "csb_chef2", function()
        return "Chef 2"
    end)
    :case("s_m_m_movalien_01", function()
        return "Alien"
    end)
    :case("a_m_m_bevhills_01", function()
        return "Beverly Hills Male"
    end)
    :case("a_m_m_skater_01", function()
        return "Skater Male"
    end)
    :case("ig_kerrymcintosh_02", function()
        return "Kerry McIntosh 2"
    end)
    :case("s_m_y_clubbar_01", function()
        return "Club Bartender Male"
    end)
    :case("s_m_m_highsec_03", function()
        return "High Security 3"
    end)
    :case("s_f_m_autoshop_01", function()
        return "Autoshop Worker Female"
    end)
    :case("u_m_m_rivalpap", function()
        return "Rival Paparazzo"
    end)
    :case("ig_dix", "csb_dix", function()
        return "Dixon"
    end)
    :case("a_m_y_gay_02", function()
        return "Gay Male 2"
    end)
    :case("ig_jackie", function()
        return "Jackie"
    end)
    :case("a_m_m_golfer_01", function()
        return "Golfer Male"
    end)
    :case("s_m_m_hairdress_01", function()
        return "Hairdresser Male"
    end)
    :case("a_m_y_musclbeac_01", function()
        return "Beach Muscle Male"
    end)
    :case("a_m_y_vinewood_04", function()
        return "Vinewood Male 4"
    end)
    :case("a_m_y_hipster_02", function()
        return "Hipster Male 2"
    end)
    :case("a_f_y_bevhills_03", function()
        return "Beverly Hills Young Female 3"
    end)
    :case("a_m_m_tourist_01", function()
        return "Tourist Male"
    end)
    :case("g_m_m_prisoners_01", function()
        return "Gang Prisoner Male"
    end)
    :case("g_m_y_salvagoon_03", function()
        return "Salvadoran Goon 3"
    end)
    :case("mp_m_execpa_01", function()
        return "Executive PA Male"
    end)
    :case("s_m_m_marine_02", function()
        return "Marine 2"
    end)
    :case("mp_m_niko_01", function()
        return "Niko Bellic"
    end)
    :case("mp_m_boatstaff_01", function()
        return "Boat-Staff Male"
    end)
    :case("s_m_y_valet_01", function()
        return "Valet"
    end)
    :case("mp_f_forgery_01", function()
        return "Biker Forgery Female"
    end)
    :case("ig_avery", "csb_avery", function()
        return "Avery Duggan"
    end)
    :case("ig_lazlow", "cs_lazlow", function()
        return "Lazlow"
    end)
    :case("mp_f_execpa_01", function()
        return "Executive PA Female"
    end)
    :case("mp_m_weapwork_01", function()
        return "Weapon Work (Male)"
    end)
    :case("s_m_m_bouncer_01", function()
        return "Bouncer"
    end)
    :case("csb_anita", function()
        return "Anita Mendoza"
    end)
    :case("mp_m_waremech_01", function()
        return "Warehouse Mechanic (Male)"
    end)
    :case("mp_m_marston_01", function()
        return "John Marston"
    end)
    :case("u_f_y_lauren", function()
        return "Lauren"
    end)
    :case("csb_porndudes", function()
        return "Porn Dude"
    end)
    :case("mp_m_forgery_01", function()
        return "Biker Forgery Male"
    end)
    :case("mp_m_exarmy_01", function()
        return "Ex-Army Male"
    end)
    :case("mp_f_misty_01", function()
        return "Misty"
    end)
    :case("mp_m_famdd_01", function()
        return "Families DD Male"
    end)
    :case("mp_m_freemode_01", function()
        return "Freemode Male"
    end)
    :case("mp_f_execpa_02", function()
        return "Executive PA Female 2"
    end)
    :case("ig_ortega", "csb_ortega", function()
        return "Ortega"
    end)
    :case("mp_m_meth_01", function()
        return "Biker Meth Male"
    end)
    :case("s_m_m_ccrew_01", function()
        return "Crew Member"
    end)
    :case("a_m_m_mlcrisis_01", function()
        return "Midlife Crisis Casino Bikers"
    end)
    :case("a_m_y_vindouche_01", function()
        return "Vinewood Douche"
    end)
    :case("a_f_y_beach_01", function()
        return "Beach Young Female"
    end)
    :case("ig_brad", "cs_brad", function()
        return "Brad"
    end)
    :case("a_c_hen", function()
        return "Hen"
    end)
    :case("ig_ashley", "cs_ashley", function()
        return "Ashley Butler"
    end)
    :case("g_m_m_chiboss_01", function()
        return "Chinese Boss"
    end)
    :case("ig_patricia", "cs_patricia", function()
        return "Patricia"
    end)
    :case("g_m_y_salvaboss_01", function()
        return "Salvadoran Boss"
    end)
    :case("a_f_y_smartcaspat_01", function()
        return "Formel Casino Guest"
    end)
    :case("g_f_y_ballas_01", function()
        return "Ballas Female"
    end)
    :case("u_m_y_staggrm_01", function()
        return "Stag Party Groom"
    end)
    :case("a_m_y_surfer_01", function()
        return "Surfer"
    end)
    :case("a_c_pig", function()
        return "Pig"
    end)
    :case("g_m_y_strpunk_02", function()
        return "Street Punk 2"
    end)
    :case("u_m_m_willyfist", function()
        return "Love Fist Willy"
    end)
    :case("player_zero", function()
        return "Michael"
    end)
    :case("s_f_y_stripper_01", "csb_stripper_01", function()
        return "Stripper"
    end)
    :case("s_m_m_marine_01", function()
        return "Marine"
    end)
    :case("g_m_y_famdnf_01", function()
        return "Families DNF Male"
    end)
    :case("g_m_m_mexboss_02", function()
        return "Mexican Boss 2"
    end)
    :case("ig_prolsec_02", "cs_prolsec_02", function()
        return "Prologue Security 2"
    end)
    :case("s_m_m_ciasec_01", function()
        return "IAA Security"
    end)
    :case("a_f_y_gencaspat_01", function()
        return "Casual Casino Guest"
    end)
    :case("g_m_m_cartelguards_02", function()
        return "Cartel Guard 2"
    end)
    :case("g_m_m_armboss_01", function()
        return "Armenian Boss"
    end)
    :case("a_m_y_roadcyc_01", function()
        return "Road Cyclist"
    end)
    :case("ig_brucie2", "csb_brucie2", function()
        return "Brucie Kibbutz"
    end)
    :case("g_m_y_armgoon_02", function()
        return "Armenian Goon 2"
    end)
    :case("g_m_y_mexgoon_01", function()
        return "Mexican Goon"
    end)
    :case("s_m_m_ammucountry", function()
        return "Ammu-Nation Rural Clerk"
    end)
    :case("s_m_m_postal_01", function()
        return "Postal Worker Male"
    end)
    :case("u_m_y_rsranger_01", function()
        return "Republican Space Ranger"
    end)
    :case("g_m_y_lost_02", function()
        return "The Lost MC Male 2"
    end)
    :case("s_m_y_xmech_02", function()
        return "MC Clubhouse Mechanic"
    end)
    :case("ig_djblamryans", function()
        return "DJ Ryan S"
    end)
    :case("ig_djblamryanh", function()
        return "DJ Ryan H"
    end)
    :case("g_m_m_armlieut_01", function()
        return "Armenian Lieutenant"
    end)
    :case("a_m_y_stbla_02", function()
        return "Black Street Male 2"
    end)
    :case("ig_oneil", function()
        return "O'Neil Brothers"
    end)
    :case("ig_djgeneric_01", function()
        return "Generic DJ"
    end)
    :case("ig_lifeinvad_02", function()
        return "Life Invader 2"
    end)
    :case("a_f_y_vinewood_04", function()
        return "Vinewood Female 4"
    end)
    :case("u_m_y_tattoo_01", function()
        return "Tattoo Artist"
    end)
    :case("ig_avon", "csb_avon", function()
        return "Avon Hertz"
    end)
    :case("ig_djsolrobt", function()
        return "DJ Rob T"
    end)
    :case("u_f_y_dancerave_01", function()
        return "Female Club Dancer (Rave)"
    end)
    :case("ig_jimmyboston_02", function()
        return "Jimmy Boston 2"
    end)
    :case("a_m_m_farmer_01", function()
        return "Farmer"
    end)
    :case("ig_lacey_jones_02", function()
        return "Lacy Jones 2"
    end)
    :case("u_m_m_markfost", function()
        return "Mark Fostenburg"
    end)
    :case("g_m_m_chigoon_02", function()
        return "Chinese Goon 2"
    end)
    :case("ig_drugdealer", function()
        return "Drugdealer"
    end)
    :case("ig_malc", function()
        return "Malc"
    end)
    :case("ig_fabien", "cs_fabien", function()
        return "Fabien"
    end)
    :case("u_f_m_miranda", function()
        return "Miranda"
    end)
    :case("ig_djdixmanager", function()
        return "DJ Dixon Manager"
    end)
    :case("ig_djsolfotios", function()
        return "DJ Fotios"
    end)
    :case("a_f_y_runner_01", function()
        return "Jogger Female"
    end)
    :case("ig_lildee", function()
        return "Lil Dee"
    end)
    :case("s_m_y_blackops_03", function()
        return "Black Ops Soldier 3"
    end)
    :case("a_c_killerwhale", function()
        return "Killer Whale"
    end)
    :case("s_m_y_marine_01", function()
        return "Marine Young"
    end)
    :case("ig_djsolmike", function()
        return "DJ Mike T"
    end)
    :case("ig_bankman", "cs_bankman", function()
        return "Bank Manager"
    end)
    :case("g_f_importexport_01", function()
        return "Import Export Female"
    end)
    :case("g_f_importexport_01", function()
        return "Gang Female (Import-Export)"
    end)
    :case("g_m_y_mexgang_01", function()
        return "Mexican Gang Member"
    end)
    :case("s_f_y_beachbarstaff_01", function()
        return "Beach Bar Staff"
    end)
    :case("s_f_m_retailstaff_01", function()
        return "Retailstaff"
    end)
    :case("s_f_m_shop_high", function()
        return "Sales Assistant (High-End)"
    end)
    :case("s_f_y_migrant_01", function()
        return "Migrant Female"
    end)
    :case("a_m_o_genstreet_01", function()
        return "General Street Old Male"
    end)
    :case("s_f_y_stripperlite", function()
        return "Stripper Lite"
    end)
    :case("ig_isldj_04", "csb_isldj_04", function()
        return "Island Dj 4"
    end)
    :case("s_f_y_clubbar_01", function()
        return "Club Bartender Female"
    end)
    :case("s_f_y_clubbar_02", function()
        return "Club Bartender Female 2"
    end)
    :case("ig_g", "csb_g", function()
        return "Gerald"
    end)
    :case("ig_money", "csb_money", function()
        return "Money Man"
    end)
    :case("u_f_m_promourn_01", function()
        return "Prologue Mourner Female"
    end)
    :case("a_m_m_polynesian_01", function()
        return "Polynesian"
    end)
    :case("u_f_m_corpse_01", function()
        return "Corpse Female"
    end)
    :case("u_f_m_miranda_02", function()
        return "Miranda 2"
    end)
    :case("u_f_y_mistress", function()
        return "Mistress"
    end)
    :case("u_f_y_dancelthr_01", function()
        return "Female Club Dancer (Leather)"
    end)
    :case("u_f_o_moviestar", function()
        return "Movie Star Female"
    end)
    :case("a_m_m_salton_03", function()
        return "Salton Male 3"
    end)
    :case("a_f_y_clubcust_02", function()
        return "Club Customer Female 2"
    end)
    :case("s_f_y_shop_mid", function()
        return "Sales Assistant (Mid-Price)"
    end)
    :case("u_f_y_bikerchic", function()
        return "Biker Chic Female"
    end)
    :case("u_f_y_poppymich", function()
        return "Poppy Mitchell"
    end)
    :case("s_m_m_drugprocess_01", function()
        return "Drug Processer"
    end)
    :case("ig_sss", "csb_sss", function()
        return "Sss"
    end)
    :case("ig_cletus", "csb_cletus", function()
        return "Cletus"
    end)
    :case("ig_tylerdix_02", function()
        return "Tyler Dixon 2"
    end)
    :case("ig_ramp_gang", "csb_ramp_gang", function()
        return "Families Gang Member?"
    end)
    :case("csb_reporter", function()
        return "Reporter"
    end)
    :case("s_m_m_highsec_04", function()
        return "High Security 4"
    end)
    :case("s_m_m_highsec_05", function()
        return "High Security 5"
    end)
    :case("s_m_m_lsmetro_01", function()
        return "LS Metro Worker Male"
    end)
    :case("a_m_m_prolhost_01", function()
        return "Prologue Host Male"
    end)
    :case("s_m_y_autopsy_01", function()
        return "Autopsy Tech"
    end)
    :case("a_m_y_hiker_01", function()
        return "Hiker Male"
    end)
    :case("s_m_m_raceorg_01", function()
        return "Racer Organisator"
    end)
    :case("s_m_y_westsec_02", function()
        return "Duggan Security 2"
    end)
    :case("ig_avischwartzman_02", function()
        return "Avi Schawrtzman"
    end)
    :case("ig_josef", "cs_josef", function()
        return "Josef"
    end)
    :case("u_m_y_justin", function()
        return "Justin"
    end)
    :case("s_m_m_migrant_01", function()
        return "Migrant Male"
    end)
    :case("mp_f_chbar_01", function()
        return "Clubhouse Bar Female"
    end)
    :case("s_m_y_grip_01", function()
        return "Grip"
    end)
    :case("s_m_y_sheriff_01", function()
        return "Sheriff Male"
    end)
    :case("a_m_y_busicas_01", function()
        return "Business Casual"
    end)
    :case("s_m_y_hwaycop_01", function()
        return "Highway Cop"
    end)
    :case("ig_priest", "cs_priest", function()
        return "Priest"
    end)
    :case("g_m_y_pologoon_02", function()
        return "Polynesian Goon 2"
    end)
    :case("s_m_y_robber_01", function()
        return "Robber"
    end)
    :case("a_m_y_genstreet_02", function()
        return "General Street Young Male 2"
    end)
    :case("ig_huang", "csb_huang", function()
        return "Huang"
    end)
    :case("s_m_y_cop_01", function()
        return "Cop Male"
    end)
    :case("g_m_m_mexboss_01", function()
        return "Mexican Boss"
    end)
    :case("a_c_cormorant", function()
        return "Cormorant"
    end)
    :case("csb_denise_friend", function()
        return "Denise's Friend"
    end)
    :case("s_m_m_lathandy_01", function()
        return "Latino Handyman Male"
    end)
    :case("ig_vincent", "csb_vincent", function()
        return "Vincent (Casino)"
    end)
    :case("g_m_m_cartelguards_01", function()
        return "Cartel Guard"
    end)
    :case("s_m_m_doctor_01", function()
        return "Doctor"
    end)
    :case("s_m_m_snowcop_01", function()
        return "Snow Cop Male"
    end)
    :case("ig_isldj_03", "csb_isldj_03", function()
        return "Island Dj 3"
    end)
    :case("s_m_y_dealer_01", function()
        return "Dealer"
    end)
    :case("u_m_m_bikehire_01", function()
        return "Bike Hire Guy"
    end)
    :case("g_m_y_lost_01", function()
        return "The Lost MC Male"
    end)
    :case("cs_carbuyer", function()
        return "Car Buyer"
    end)
    :case("g_m_y_ballasout_01", function()
        return "Ballas South Male"
    end)
    :case("ig_ramp_hipster", "csb_ramp_hipster", function()
        return "Hipster"
    end)
    :case("ig_ramp_mex", "csb_ramp_mex", function()
        return "Mexican"
    end)
    :case("s_m_m_cntrybar_01", function()
        return "Bartender (Rural)"
    end)
    :case("s_m_m_gentransport", function()
        return "Transport Worker Male"
    end)
    :case("ig_agatha", "csb_agatha", function()
        return "Agatha Baker"
    end)
    :case("ig_lamardavis", "cs_lamardavis", function()
        return "Lamar Davis"
    end)
    :case("ig_lamardavis_02", "cs_lamardavis_02", function()
        return "Lamar Davis 2"
    end)
    :case("ig_tonyprince", "csb_tonyprince", function()
        return "Tony Prince"
    end)
    :case("cs_debra", function()
        return "Debra"
    end)
    :case("ig_lestercrest", "cs_lestercrest", function()
        return "Lester Crest"
    end)
    :case("ig_gustavo", "csb_gustavo", function()
        return "Gustavo"
    end)
    :case("csb_bryony", function()
        return "Bryony"
    end)
    :case("u_m_y_abner", function()
        return "Abner"
    end)
    :case("ig_taostranslator", "cs_taostranslator", function()
        return "Tao's Translator"
    end)
    :case("mp_f_helistaff_01", function()
        return "Heli-Staff Female"
    end)
    :case("a_m_y_ktown_01", function()
        return "Korean Young Male"
    end)
    :case("cs_martinmadrazo", function()
        return "Martin Madrazo"
    end)
    :case("ig_hao", "csb_hao", function()
        return "Hao"
    end)
    :case("a_m_y_hippy_01", "u_m_y_hippie_01", function()
        return "Hippie Male"
    end)
    :case("cs_guadalope", function()
        return "Guadalope"
    end)
    :case("g_f_y_families_01", function()
        return "Families Female"
    end)
    :case("a_m_y_dhill_01", function()
        return "Downhill Cyclist"
    end)
    :case("u_f_y_comjane", function()
        return "Jane"
    end)
    :case("ig_hunter", "cs_hunter", function()
        return "Hunter"
    end)
    :case("ig_jimmydisanto", "cs_jimmydisanto", function()
        return "Jimmy De Santa"
    end)
    :case("s_f_y_stripper_02", "csb_stripper_02", function()
        return "Stripper 2"
    end)
    :case("ig_patricia_02", "cs_patricia_02", function()
        return "Patricia 2"
    end)
    :case("u_m_o_finguru_01", function()
        return "Financial Guru"
    end)
    :case("s_m_m_highsec_01", function()
        return "High Security"
    end)
    :case("ig_floyd", "cs_floyd", function()
        return "Floyd Hebert"
    end)
    :case("a_m_m_socenlat_01", function()
        return "South Central Latino Male"
    end)
    :case("p_franklin_02", "player_one", function()
        return "Franklin"
    end)
    :case("a_f_y_soucent_03", function()
        return "South Central Young Female 3"
    end)
    :case("ig_mjo", "csb_mjo", function()
        return "Mjo"
    end)
    :case("ig_mjo_02", "csb_mjo_02", function()
        return "Mjo 2"
    end)
    :case("s_f_y_sweatshop_01", function()
        return "Sweatshop Worker Young"
    end)
    :case("a_m_y_business_03", function()
        return "Business Young Male 3"
    end)
    :case("ig_devin", "cs_devin", function()
        return "Devin"
    end)
    :case("u_m_y_gabriel", function()
        return "Gabriel"
    end)
    :case("ig_miguelmadrazo", "csb_miguelmadrazo", function()
        return "Miguel Madrazo"
    end)
    :case("a_m_m_tranvest_02", function()
        return "Transvestite Male 2"
    end)
    :case("ig_casey", "cs_casey", function()
        return "Casey"
    end)
    :case("a_c_boar", function()
        return "Boar"
    end)
    :case("a_m_m_eastsa_02", function()
        return "East SA Male 2"
    end)
    :case("g_m_m_casrn_01", function()
        return "Casino Guests?"
    end)
    :case("ig_old_man1a", "cs_old_man1a", function()
        return "Old Man 1"
    end)
    :case("u_m_o_filmnoir", function()
        return "Movie Corpse (Suited)"
    end)
    :case("s_m_m_prisguard_01", function()
        return "Prison Guard"
    end)
    :case("ig_kaylee", function()
        return "Kaylee"
    end)
    :case("a_m_y_musclbeac_02", function()
        return "Beach Muscle Male 2"
    end)
    :case("a_f_m_genbiker_01", function()
        return "Biker Female"
    end)
    :case("a_f_y_studioparty_01", function()
        return "Studio Female"
    end)
    :case("a_f_y_studioparty_02", function()
        return "Studio Female 2"
    end)
    :case("a_m_m_genbiker_01", function()
        return "Biker Male"
    end)
    :case("a_m_m_studioparty_01", "a_m_y_studioparty_01", function()
        return "Studio Male"
    end)
    :case("cs_mrk", function()
        return "Mr. K"
    end)
    :case("cs_russiandrunk", function()
        return "Drunk Russian"
    end)
    :case("ig_ballas_leader", "csb_ballas_leader", function()
        return "Ballas Leader"
    end)
    :case("ig_billionaire", "csb_billionaire", function()
        return "Billionaire"
    end)
    :case("csb_car3guy1", function()
        return "Car Guy"
    end)
    :case("csb_chin_goon", function()
        return "Chin Goon"
    end)
    :case("ig_golfer_a", "csb_golfer_a", function()
        return "Golfer"
    end)
    :case("ig_golfer_b", "csb_golfer_b", function()
        return "Golfer 2"
    end)
    :case("ig_imani", "csb_imani", function()
        return "Imani"
    end)
    :case("ig_johnny_guns", "csb_johnny_guns", function()
        return "Johnny Guns"
    end)
    :case("ig_musician_00", "csb_musician_00", function()
        return "Musician"
    end)
    :case("ig_party_promo", "csb_party_promo", function()
        return "Party Promo"
    end)
    :case("csb_ramp_marine", function()
        return "Marine"
    end)
    :case("ig_req_officer", "csb_req_officer", function()
        return "Officer"
    end)
    :case("ig_security_a", "csb_security_a", function()
        return "Security"
    end)
    :case("ig_soundeng_00", "csb_soundeng_00", function()
        return "Sound"
    end)
    :case("ig_vagos_leader", "csb_vagos_leader", function()
        return "Vagos Leader"
    end)
    :case("ig_vernon", "csb_vernon", function()
        return "Vernon"
    end)
    :case("g_m_m_genthug_01", function()
        return "Thug"
    end)
    :case("g_m_m_goons_01", function()
        return "Goons"
    end)
    :case("g_m_y_korean_01", function()
        return "Korean"
    end)
    :case("g_m_y_korean_02", function()
        return "Korean 2"
    end)
    :case("ig_entourage_a", function()
        return "Entourage"
    end)
    :case("ig_entourage_b", function()
         return "Entourage 2"
    end)
    :case("ig_mason_duggan", function()
        return "Mason Duggan"
    end)
    :case("ig_warehouseboss", function()
        return "Warehouse Boss"
    end)
    :case("mp_headtargets", function()
        return "Headtargets"
    end)
    :case("s_f_m_studioassist_01", function()
        return "Studio Assistant Female"
    end)
    :case("s_m_m_studioassist_02", function()
        return "Studio Assistant"
    end)
    :case("s_m_m_studioprod_01", function()
        return "Studio Producer"
    end)
    :case("s_m_m_studiosoueng_02", function()
        return "Studio Sound"
    end)
    :case("s_f_m_warehouse_01", function()
        return "Warehouse Worker Female"
    end)
    :case("s_m_m_warehouse_01", function()
        return "Warehouse Worker"
    end)
    :case("s_m_m_dockwork_01", function()
        return "Dock Worker"
    end)
    :case("u_f_m_drowned_01", function()
        return "Drowned Female"
    end)


ped.sorted = {}
for i = 1, 13
do
    ped.sorted[i] = {}
end

ped.models = {}

for line in io.lines(files["PedList"])
do
    insert(ped.models, line)
    if line:find("^a_f_") then
        insert(ped.sorted[1], line)
    elseif line:find("^a_m_") then
        insert(ped.sorted[2], line)
    elseif line:find("^a_c_") then
        insert(ped.sorted[3], line)
    elseif line:find("^cs") then
        insert(ped.sorted[4], line)
    elseif line:find("^g_f_") then
        insert(ped.sorted[5], line)
    elseif line:find("^g_m_") then
        insert(ped.sorted[6], line)
    elseif line:find("^mp_") then
        insert(ped.sorted[7], line)
    elseif line:find("^s_f_") then
        insert(ped.sorted[8], line)
    elseif line:find("^s_m_") then
        insert(ped.sorted[9], line)
    elseif line:find("^hc_") or line:find("^ig_") then
        insert(ped.sorted[10], line)
    elseif line:find("^u_f_") then
        insert(ped.sorted[11], line)
    elseif line:find("^u_m_") then
        insert(ped.sorted[12], line)
    else
        insert(ped.sorted[13], line)
    end
end

for _, v in ipairs(ped.models)
do
    if not ped.GetPedName(v) then
        system.log('debug', v)
    end
end

ped.anims = {
    {"Pole Dance", "mini@strip_club@pole_dance@pole_dance3", "pd_dance_03"},
    {"Hood Dance", "missfbi3_sniping", "dance_m_default"},
    {"Burning", "ragdoll@human", "on_fire"},
    {"Getting Stunned", "ragdoll@human", "electrocute"},
    {"Private Dance", "mini@strip_club@private_dance@part1", "priv_dance_p1"},
    {"The Rear Abundance", "rcmpaparazzo_2", "shag_loop_poppy"},
    {"The Invisible Man", "rcmpaparazzo_2", "shag_loop_a"},
    {"Push ups", "amb@world_human_push_ups@male@base", "base"},
    {"Sit ups", "amb@world_human_sit_ups@male@base", "base"},
    {"Wave Yo' Arms", "random@car_thief@victimpoints_ig_3", "arms_waving"},
    {"Give BJ to Driver", "mini@prostitutes@sexnorm_veh", "bj_loop_prostitute"},
    {"Pleasure Driver", "mini@prostitutes@sexnorm_veh", "sex_loop_prostitute"},
    {"Mime", "special_ped@mime@monologue_8@monologue_8a", "08_ig_1_wall_ba_0"},
    {"Mime 2", "special_ped@mime@monologue_7@monologue_7a", "11_ig_1_run_aw_0"},
    {"Throw", "switch@franklin@throw_cup", "throw_cup_loop"},
    {"Smoke Coughing", "timetable@gardener@smoking_joint", "idle_cough"},
    {"Chilling with Friends", "friends@laf@ig_1@base", "base"},
    {"They Think We Dumb", "timetable@ron@they_think_were_stupid", "they_think_were_stupid"},
    {"Come Here", "gestures@m@standing@fat", "gesture_come_here_hard"},
    {"No Way", "gestures@m@standing@fat", "gesture_no_way"},
    {"They're Gonna Kill Me", "random@bicycle_thief@ask_help", "my_dads_going_to_kill_me"},
    {"You Gotta Help Me", "random@bicycle_thief@ask_help", "please_man_you_gotta_help_me"},
    {"Sleep", "savecouch@", "t_sleep_loop_couch"},
    {"Sleep 2", "savem_default@", "m_sleep_r_loop"},
    {"Sleep 3", "timetable@tracy@sleep@", "idle_c"},
    {"Meditate", "rcmcollect_paperleadinout@", "meditiate_idle"},
    {"Fap", "switch@trevor@jerking_off", "trev_jerking_off_loop"},
    {"Yeah Yeah Yeah", "special_ped@jessie@michael_1@michael_1b", "jessie_ig_2_yeahyeahyeah_1"},
    {"Idle On Laptop", "switch@franklin@on_laptop", "001927_01_fras_v2_4_on_laptop_idle"},
    {"Hands Up", "random@arrests", "idle_2_hands_up"},
    {"Stand Still, Arms Spread", "mp_sleep", "bind_pose_180"},
    {"Dog Sitting", "creatures@pug@amb@world_dog_sitting@base", "base"},
    {"Amanda Pleasure", "timetable@amanda@ig_6", "ig_6_base"},
    {"Toilet", "switch@trevor@on_toilet", "trev_on_toilet_loop"},
    {"???", "anim@veh@armordillo@turret@base", "fire"},
    {"T-pose", "mp_intro_concat-3", "mp_m_freemode_01_dual-3"},
    {"Cow Grazing", "creatures@cow@amb@world_cow_grazing@base", "base"},
    {"Deer Walk", "creatures@deer@move", "walk"},
    {"Dolphin Dying", "creatures@dolphin@move", "dying"},
    {"Retriever Attack" , "creatures@retriever@melee@streamed_core@", "attack"},
}

ped.scenario = {
    { "Drilling", "WORLD_HUMAN_CONST_DRILL" },
    { "Hammering", "WORLD_HUMAN_HAMMERING" },
    { "Mechanic", "WORLD_HUMAN_VEHICLE_MECHANIC" },
    { "Janitor", "WORLD_HUMAN_JANITOR" },
    { "Hang Out", "WORLD_HUMAN_HANG_OUT_STREET" },
    { "Play Guitar", "WORLD_HUMAN_MUSICIAN_MALE_BONGOS" },
    { "Play Bongos", "WORLD_HUMAN_MUSICIAN_MALE_GUITAR" },
    { "Clipboard", "WORLD_HUMAN_CLIPBOARD" },
    { "Smoking", "WORLD_HUMAN_SMOKING" },
    { "Smoking 2", "WORLD_HUMAN_AA_SMOKE" },
    { "Smoking Weed", "WORLD_HUMAN_SMOKING_POT" },
    { "Standing With Phone", "WORLD_HUMAN_STAND_MOBILE" },
    { "Standing With Phone 2", "WORLD_HUMAN_STAND_MOBILE_UPRIGHT" },
    { "Standing Guard", "WORLD_HUMAN_GUARD_STAND" },
    { "Standing Impatiently", "WORLD_HUMAN_STAND_IMPATIENT" },
    { "Standing Impatiently 2", "WORLD_HUMAN_STAND_IMPATIENT_UPRIGHT" },
    { "Soldier Stand", "WORLD_HUMAN_GUARD_STAND_ARMY" },
    { "Hobo Stand", "WORLD_HUMAN_BUM_STANDING" },
    { "Doing Pushups", "WORLD_HUMAN_PUSH_UPS" },
    { "Lifting Weights", "WORLD_HUMAN_MUSCLE_FREE_WEIGHTS" },
    { "Flexing", "WORLD_HUMAN_MUSCLE_FLEX" },
    { "Drug Dealer", "WORLD_HUMAN_DRUG_DEALER_HARD" },
    { "Hooker", "WORLD_HUMAN_PROSTITUTE_LOW_CLASS" },
    { "Hooker 2", "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS" },
    { "Drunk", "WORLD_HUMAN_STUPOR" },
    { "Drinking", "WORLD_HUMAN_DRINKING" },
    { "Drinking Coffee", "WORLD_HUMAN_AA_COFFEE" },
    { "Binoculars", "WORLD_HUMAN_BINOCULARS" },
    { "Welding", "WORLD_HUMAN_WELDING" },
    { "Shocked", "WORLD_HUMAN_MOBILE_FILM_SHOCKING" },
    { "Taking Pictures", "WORLD_HUMAN_PAPARAZZI" },
    { "Medic", "CODE_HUMAN_MEDIC_KNEEL" },
    { "Window Shopping", "WORLD_HUMAN_WINDOW_SHOP_BROWSE" },
    { "Cleaning", "WORLD_HUMAN_MAID_CLEAN" },
    { "Doing Yoga", "WORLD_HUMAN_YOGA" },
    { "Tourist Map", "WORLD_HUMAN_TOURIST_MAP" },
    { "Tennis Player", "WORLD_HUMAN_TENNIS_PLAYER" },
    { "Sunbathing", "WORLD_HUMAN_SUNBATHE" },
    { "Sunbathing 2", "WORLD_HUMAN_SUNBATHE_BACK" },
    { "Fishing", "WORLD_HUMAN_STAND_FISHING" },
    { "Shining Torch", "WORLD_HUMAN_SECURITY_SHINE_TORCH" },
    { "Picnic", "WORLD_HUMAN_PICNIC" },
    { "Partying", "WORLD_HUMAN_PARTYING" },
    { "Leaning", "WORLD_HUMAN_LEANING" },
    { "Jog Standing", "WORLD_HUMAN_JOG_STANDING" },
    { "Human Statue", "WORLD_HUMAN_HUMAN_STATUE" },
    { "Hanging Out (Street)", "WORLD_HUMAN_HANG_OUT_STREET" },
    { "Golf Player", "WORLD_HUMAN_GOLF_PLAYER" },
    { "Gardening", "WORLD_HUMAN_GARDENER_PLANT" },
    { "Drug Dealing", "WORLD_HUMAN_DRUG_DEALER_HARD" },
    { "Cheering", "WORLD_HUMAN_CHEERING" },
    { "Parking Attendant", "WORLD_HUMAN_CAR_PARK_ATTENDANT" },
    { "Wash", "WORLD_HUMAN_BUM_WASH" },
    { "Holding Sign", "WORLD_HUMAN_BUM_FREEWAY" },
    { "Laying Down (Hobo)", "WORLD_HUMAN_BUM_SLUMPED" },
    { "BBQ", "PROP_HUMAN_BBQ" },
}


function ped.get_table_names(tabl)
    local peds = {}
    for i, v in ipairs(tabl)
    do
        peds[i] = ped.GetPedName(v) or v
    end
    return peds
end

function ped.is_ped_an_enemy(cped)
    local relationship = PED.GET_RELATIONSHIP_BETWEEN_PEDS(PLAYER.PLAYER_PED_ID(), cped)
    if ENTITY.IS_ENTITY_DEAD(cped, false) == 0 and ((relationship == 4 or relationship == 5) or PED.IS_PED_IN_COMBAT(cped, PLAYER.PLAYER_PED_ID()) == 1) then
        return true
    end
end

function ped.calm_ped(cped, toggle)
    if ENTITY.IS_ENTITY_A_PED(cped) == 0 then return end 
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(cped)
    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(cped, toggle)
    PED.SET_PED_FLEE_ATTRIBUTES(cped, 0, not toggle)
    PED.SET_PED_COMBAT_ATTRIBUTES(cped, 17, toggle)
end

function ped.set_ped_god(cped)
    ENTITY.SET_ENTITY_INVINCIBLE(cped, true)
    ENTITY.SET_ENTITY_PROOFS(cped, true, true, true, true, true, true, true, true)
    PED.SET_PED_DIES_IN_WATER(cped, false)
    PED.SET_PED_DIES_IN_SINKING_VEHICLE(cped, false)
    PED.SET_PED_DIES_IN_VEHICLE(cped, false)
    PED.SET_PED_DIES_WHEN_INJURED(cped, false)
    PED._SET_PED_CAN_PLAY_INJURED_ANIMS(cped, false) 
    PED.SET_PED_CAN_RAGDOLL(cped, false)
    PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(cped, false)
    for _, v in ipairs({1,2,4}) do
        PED.SET_RAGDOLL_BLOCKING_FLAGS(cped, v)
    end
end

function ped.play_scenario(ped, scenario)
    TASK.TASK_START_SCENARIO_IN_PLACE(ped, scenario, -1, false)
end

function ped.play_anim(ped, anim_dict, anim_name, blend_in_speed, blend_out_speed, duration, flags, playback_rate, lock)
    if TASK.IS_PED_ACTIVE_IN_SCENARIO(ped) == 1 then
        TASK.PLAY_ANIM_ON_RUNNING_SCENARIO(ped, anim_dict, anim_name)
    else
        TASK.TASK_PLAY_ANIM(ped, anim_dict, anim_name, blend_in_speed, blend_out_speed, duration, flags, playback_rate, lock, lock, lock)
    end
end

function ped.revive(ped)
    local anim_dict = "get_up@directional@movement@from_knees@standard"
    local anim_name = "getup_r_90"
    local tick = 0
    CreateRemoveThread(true, 'revive_'..ped, function()
        if STREAMING.HAS_ANIM_DICT_LOADED(anim_dict) == 0 then
            STREAMING.REQUEST_ANIM_DICT(anim_dict)
            return
        end
        tick = tick + 1
        if tick == 1 then
            entities.request_control(ped, function()
                ENTITY.SET_ENTITY_HEALTH(ped, 200, 0)
                ENTITY.SET_ENTITY_MAX_HEALTH(ped, 400)
                PED.RESURRECT_PED(ped)
                PED.REVIVE_INJURED_PED(ped)
                ENTITY.SET_ENTITY_HEALTH(ped, 200, 0)
                PED.SET_PED_GENERATES_DEAD_BODY_EVENTS(ped, false)
                PED.SET_PED_CONFIG_FLAG(ped, 166, false)
                PED.SET_PED_CONFIG_FLAG(ped, 187, false)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                peds.play_anim(ped, anim_dict, anim_name, 8, -8, -1, enum.anim_flag.StopOnLastFrame, 0, false)
            end)
        end
        if tick < 100 then return end
        entities.request_control(ped, function()
            TASK.TASK_WANDER_STANDARD(ped, 10, 10)
        end)
        STREAMING.REMOVE_ANIM_DICT(anim_dict)
        return POP_THREAD
    end)
end


function ped.create_ped(hash, pos, god, invisible, face_entity, ...)
    local flags = {...}
    if STREAMING.IS_MODEL_VALID(hash) == 0 then return end
    local cped = entities.create_ped(hash, pos.x, pos.y, pos.z)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(cped, false, true)
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(cped)
    if face_entity then
        features.set_entity_face_entity(cped, face_entity)
    end
    if god then
        ped.set_ped_god(cped)
    end
    if invisible then
        ENTITY.SET_ENTITY_VISIBLE(cped, false, false)
    end
    if flags then
        for _, v in ipairs(flags) do
            PED.SET_PED_CONFIG_FLAG(cped, v, true)
        end
    end
    return cped
end

function ped.get_weapons(ped)
    local ped = ped or PLAYER.PLAYER_PED_ID()
    local weapon = {}
    for _, v in ipairs(weapons.data)
    do
        if WEAPON.HAS_PED_GOT_WEAPON(ped, v.Hash, false) == 1 then
            local Components = {}
            for _, e in ipairs(v.Components)
            do
                if WEAPON.HAS_PED_GOT_WEAPON_COMPONENT(ped, v.Hash, e.Hash) == 1 then
                    insert(Components, e.Hash)
                end
            end
            insert(weapon, {
                Hash = v.Hash,
                Tint = WEAPON.GET_PED_WEAPON_TINT_INDEX(ped, v.Hash),
                Components = Components
            })
        end
    end
    return weapon
end

function ped.set_weapons(weapon, ped)
    if not weapon then return end
    local ped = ped or PLAYER.PLAYER_PED_ID()
    WEAPON.REMOVE_ALL_PED_WEAPONS(ped, false)
    for _, v in ipairs(weapon) do
        if WEAPON.HAS_PED_GOT_WEAPON(ped, v.Hash, false) == 0 then
            WEAPON.GIVE_WEAPON_TO_PED(ped, v.Hash, 9999, false, false)
            for _, e in ipairs(v.Components)
            do
                if WEAPON.HAS_PED_GOT_WEAPON_COMPONENT(ped, v.Hash, e) == 0 then
                    WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(ped, v.Hash, e)
                end
            end
            WEAPON.SET_PED_WEAPON_TINT_INDEX(ped, v.Hash, v.Tint)
        end
    end
end

function ped.get_outfit(ped)
    local ped = ped or PLAYER.PLAYER_PED_ID()
    local outfit = {components = {}, props = {}}
    for i = 0, 11 do
        outfit.components[i] = {
            PED.GET_PED_DRAWABLE_VARIATION(ped, i), 
            PED.GET_PED_TEXTURE_VARIATION(ped, i)
        }
    end
    for i = 0, 9 do
        outfit.props[i] = {
            PED.GET_PED_PROP_INDEX(ped, i),
            PED.GET_PED_PROP_TEXTURE_INDEX(ped, i)
        }
    end
    return outfit
end

function ped.apply_outfit(components, props, ped)
    local ped = ped or PLAYER.PLAYER_PED_ID()
    for k, v in pairs(components)
    do
        PED.SET_PED_COMPONENT_VARIATION(ped, tonumber(k), v[1], v[2], 0)
    end
    for k, v in pairs(props)
    do
        if v[1] == -1 then
            PED.CLEAR_PED_PROP(ped, tonumber(k))
        else
            PED.SET_PED_PROP_INDEX(ped, tonumber(k), v[1], v[2], true)
        end
    end
end

return ped