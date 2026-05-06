<?php
// api.php - Main API Handler for Railway Reservation System

require_once 'config.php';

$database = new Database();
$db = $database->connect();

// Get request method and action
$method = $_SERVER['REQUEST_METHOD'];
$action = isset($_GET['action']) ? $_GET['action'] : '';
$table = isset($_GET['table']) ? $_GET['table'] : '';

// Response function
function sendResponse($success, $data = null, $message = '') {
    echo json_encode([
        'success' => $success,
        'data' => $data,
        'message' => $message
    ]);
    exit();
}

// ============================================
// ROUTE OPERATIONS
// ============================================
if ($table === 'route') {
    if ($method === 'GET' && $action === 'list') {
        try {
            $stmt = $db->query("SELECT * FROM ROUTE ORDER BY route_id DESC");
            $routes = $stmt->fetchAll();
            sendResponse(true, $routes);
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'POST' && $action === 'create') {
        $data = json_decode(file_get_contents("php://input"), true);
        try {
            $stmt = $db->prepare("INSERT INTO ROUTE (source, destination, distance_km, duration_hours) VALUES (?, ?, ?, ?)");
            $stmt->execute([$data['source'], $data['destination'], $data['distance_km'], $data['duration_hours']]);
            sendResponse(true, ['id' => $db->lastInsertId()], 'Route created successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'PUT' && $action === 'update') {
        $data = json_decode(file_get_contents("php://input"), true);
        try {
            $stmt = $db->prepare("UPDATE ROUTE SET source=?, destination=?, distance_km=?, duration_hours=? WHERE route_id=?");
            $stmt->execute([$data['source'], $data['destination'], $data['distance_km'], $data['duration_hours'], $data['route_id']]);
            sendResponse(true, null, 'Route updated successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'DELETE' && $action === 'delete') {
        $id = isset($_GET['id']) ? $_GET['id'] : 0;
        try {
            $stmt = $db->prepare("DELETE FROM ROUTE WHERE route_id = ?");
            $stmt->execute([$id]);
            sendResponse(true, null, 'Route deleted successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
}

// ============================================
// TRAIN OPERATIONS
// ============================================
if ($table === 'train') {
    if ($method === 'GET' && $action === 'list') {
        try {
            $stmt = $db->query("
                SELECT t.*, r.source, r.destination, r.distance_km, r.duration_hours 
                FROM TRAIN t 
                LEFT JOIN ROUTE r ON t.route_id = r.route_id 
                ORDER BY t.train_id DESC
            ");
            $trains = $stmt->fetchAll();
            sendResponse(true, $trains);
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'POST' && $action === 'create') {
        $data = json_decode(file_get_contents("php://input"), true);
        try {
            $stmt = $db->prepare("INSERT INTO TRAIN (train_name, train_number, train_type, total_seats, route_id, departure_time, arrival_time, days_of_operation, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([
                $data['train_name'], 
                $data['train_number'], 
                $data['train_type'], 
                $data['total_seats'], 
                $data['route_id'],
                $data['departure_time'],
                $data['arrival_time'],
                $data['days_of_operation'],
                $data['status']
            ]);
            sendResponse(true, ['id' => $db->lastInsertId()], 'Train created successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'PUT' && $action === 'update') {
        $data = json_decode(file_get_contents("php://input"), true);
        try {
            $stmt = $db->prepare("UPDATE TRAIN SET train_name=?, train_number=?, train_type=?, total_seats=?, route_id=?, departure_time=?, arrival_time=?, days_of_operation=?, status=? WHERE train_id=?");
            $stmt->execute([
                $data['train_name'], 
                $data['train_number'], 
                $data['train_type'], 
                $data['total_seats'], 
                $data['route_id'],
                $data['departure_time'],
                $data['arrival_time'],
                $data['days_of_operation'],
                $data['status'],
                $data['train_id']
            ]);
            sendResponse(true, null, 'Train updated successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'DELETE' && $action === 'delete') {
        $id = isset($_GET['id']) ? $_GET['id'] : 0;
        try {
            $stmt = $db->prepare("DELETE FROM TRAIN WHERE train_id = ?");
            $stmt->execute([$id]);
            sendResponse(true, null, 'Train deleted successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
}

// ============================================
// PASSENGER OPERATIONS
// ============================================
if ($table === 'passenger') {
    if ($method === 'GET' && $action === 'list') {
        try {
            $stmt = $db->query("SELECT * FROM PASSENGER ORDER BY passenger_id DESC");
            $passengers = $stmt->fetchAll();
            sendResponse(true, $passengers);
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'POST' && $action === 'create') {
        $data = json_decode(file_get_contents("php://input"), true);
        try {
            $stmt = $db->prepare("INSERT INTO PASSENGER (first_name, last_name, email, phone, date_of_birth, gender, address, id_proof_type, id_proof_number) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([
                $data['first_name'],
                $data['last_name'],
                $data['email'],
                $data['phone'],
                $data['date_of_birth'],
                $data['gender'],
                $data['address'],
                $data['id_proof_type'],
                $data['id_proof_number']
            ]);
            sendResponse(true, ['id' => $db->lastInsertId()], 'Passenger created successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'PUT' && $action === 'update') {
        $data = json_decode(file_get_contents("php://input"), true);
        try {
            $stmt = $db->prepare("UPDATE PASSENGER SET first_name=?, last_name=?, email=?, phone=?, date_of_birth=?, gender=?, address=?, id_proof_type=?, id_proof_number=? WHERE passenger_id=?");
            $stmt->execute([
                $data['first_name'],
                $data['last_name'],
                $data['email'],
                $data['phone'],
                $data['date_of_birth'],
                $data['gender'],
                $data['address'],
                $data['id_proof_type'],
                $data['id_proof_number'],
                $data['passenger_id']
            ]);
            sendResponse(true, null, 'Passenger updated successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'DELETE' && $action === 'delete') {
        $id = isset($_GET['id']) ? $_GET['id'] : 0;
        try {
            $stmt = $db->prepare("DELETE FROM PASSENGER WHERE passenger_id = ?");
            $stmt->execute([$id]);
            sendResponse(true, null, 'Passenger deleted successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
}

// ============================================
// TICKET OPERATIONS
// ============================================
if ($table === 'ticket') {
    if ($method === 'GET' && $action === 'list') {
        try {
            $stmt = $db->query("SELECT * FROM ticket_details ORDER BY ticket_id DESC");
            $tickets = $stmt->fetchAll();
            sendResponse(true, $tickets);
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'POST' && $action === 'create') {
        $data = json_decode(file_get_contents("php://input"), true);
        try {
            // Generate PNR
            $pnr = 'PNR' . str_pad(rand(1, 9999999), 7, '0', STR_PAD_LEFT);
            
            // Generate seat number
            $seatPrefix = [
                'Sleeper' => 'S',
                '3AC' => 'B',
                '2AC' => 'A',
                '1AC' => 'F'
            ];
            $prefix = $seatPrefix[$data['seat_class']];
            $seatNumber = $prefix . rand(1, 10) . '-' . rand(1, 72);
            
            $stmt = $db->prepare("INSERT INTO TICKET (pnr_number, passenger_id, train_id, journey_date, seat_number, seat_class, ticket_status, fare) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([
                $pnr,
                $data['passenger_id'],
                $data['train_id'],
                $data['journey_date'],
                $seatNumber,
                $data['seat_class'],
                $data['ticket_status'],
                $data['fare']
            ]);
            
            // Update seat availability
            $updateStmt = $db->prepare("UPDATE SEAT_AVAILABILITY SET available_seats = available_seats - 1 WHERE train_id = ? AND journey_date = ?");
            $updateStmt->execute([$data['train_id'], $data['journey_date']]);
            
            sendResponse(true, ['id' => $db->lastInsertId(), 'pnr' => $pnr, 'seat' => $seatNumber], 'Ticket booked successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'PUT' && $action === 'update') {
        $data = json_decode(file_get_contents("php://input"), true);
        try {
            $stmt = $db->prepare("UPDATE TICKET SET ticket_status=? WHERE ticket_id=?");
            $stmt->execute([$data['ticket_status'], $data['ticket_id']]);
            sendResponse(true, null, 'Ticket updated successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'DELETE' && $action === 'delete') {
        $id = isset($_GET['id']) ? $_GET['id'] : 0;
        try {
            $stmt = $db->prepare("DELETE FROM TICKET WHERE ticket_id = ?");
            $stmt->execute([$id]);
            sendResponse(true, null, 'Ticket deleted successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
}

// ============================================
// PAYMENT OPERATIONS
// ============================================
if ($table === 'payment') {
    if ($method === 'GET' && $action === 'list') {
        try {
            $stmt = $db->query("
                SELECT p.*, t.pnr_number, t.fare 
                FROM PAYMENT p 
                LEFT JOIN TICKET t ON p.ticket_id = t.ticket_id 
                ORDER BY p.payment_id DESC
            ");
            $payments = $stmt->fetchAll();
            sendResponse(true, $payments);
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'POST' && $action === 'create') {
        $data = json_decode(file_get_contents("php://input"), true);
        try {
            // Generate transaction ID
            $txnId = 'TXN' . time() . rand(1000, 9999);
            
            $stmt = $db->prepare("INSERT INTO PAYMENT (ticket_id, amount, payment_method, payment_status, transaction_id) VALUES (?, ?, ?, ?, ?)");
            $stmt->execute([
                $data['ticket_id'],
                $data['amount'],
                $data['payment_method'],
                $data['payment_status'],
                $txnId
            ]);
            sendResponse(true, ['id' => $db->lastInsertId(), 'transaction_id' => $txnId], 'Payment processed successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'PUT' && $action === 'update') {
        $data = json_decode(file_get_contents("php://input"), true);
        try {
            $stmt = $db->prepare("UPDATE PAYMENT SET payment_status=? WHERE payment_id=?");
            $stmt->execute([$data['payment_status'], $data['payment_id']]);
            sendResponse(true, null, 'Payment updated successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
}

// ============================================
// SEAT AVAILABILITY OPERATIONS
// ============================================
if ($table === 'seat_availability') {
    if ($method === 'GET' && $action === 'list') {
        try {
            $stmt = $db->query("
                SELECT sa.*, t.train_name, t.train_number 
                FROM SEAT_AVAILABILITY sa 
                LEFT JOIN TRAIN t ON sa.train_id = t.train_id 
                ORDER BY sa.journey_date DESC
            ");
            $availability = $stmt->fetchAll();
            sendResponse(true, $availability);
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'POST' && $action === 'create') {
        $data = json_decode(file_get_contents("php://input"), true);
        try {
            $stmt = $db->prepare("INSERT INTO SEAT_AVAILABILITY (train_id, journey_date, total_seats, available_seats, sleeper_available, ac_3tier_available, ac_2tier_available, ac_1tier_available) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([
                $data['train_id'],
                $data['journey_date'],
                $data['total_seats'],
                $data['available_seats'],
                $data['sleeper_available'],
                $data['ac_3tier_available'],
                $data['ac_2tier_available'],
                $data['ac_1tier_available']
            ]);
            sendResponse(true, ['id' => $db->lastInsertId()], 'Seat availability created successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
    
    if ($method === 'PUT' && $action === 'update') {
        $data = json_decode(file_get_contents("php://input"), true);
        try {
            $stmt = $db->prepare("UPDATE SEAT_AVAILABILITY SET available_seats=?, sleeper_available=?, ac_3tier_available=?, ac_2tier_available=?, ac_1tier_available=? WHERE availability_id=?");
            $stmt->execute([
                $data['available_seats'],
                $data['sleeper_available'],
                $data['ac_3tier_available'],
                $data['ac_2tier_available'],
                $data['ac_1tier_available'],
                $data['availability_id']
            ]);
            sendResponse(true, null, 'Seat availability updated successfully');
        } catch(PDOException $e) {
            sendResponse(false, null, $e->getMessage());
        }
    }
}

// ============================================
// DASHBOARD STATISTICS
// ============================================
if ($action === 'dashboard') {
    try {
        $stats = [];
        
        // Total routes
        $stmt = $db->query("SELECT COUNT(*) as count FROM ROUTE");
        $stats['total_routes'] = $stmt->fetch()['count'];
        
        // Total trains
        $stmt = $db->query("SELECT COUNT(*) as count FROM TRAIN WHERE status = 'Active'");
        $stats['total_trains'] = $stmt->fetch()['count'];
        
        // Total passengers
        $stmt = $db->query("SELECT COUNT(*) as count FROM PASSENGER");
        $stats['total_passengers'] = $stmt->fetch()['count'];
        
        // Total bookings
        $stmt = $db->query("SELECT COUNT(*) as count FROM TICKET");
        $stats['total_bookings'] = $stmt->fetch()['count'];
        
        // Today's bookings
        $stmt = $db->query("SELECT COUNT(*) as count FROM TICKET WHERE DATE(booking_date) = CURDATE()");
        $stats['today_bookings'] = $stmt->fetch()['count'];
        
        // Total revenue
        $stmt = $db->query("SELECT SUM(amount) as revenue FROM PAYMENT WHERE payment_status = 'Success'");
        $stats['total_revenue'] = $stmt->fetch()['revenue'] ?: 0;
        
        // Recent bookings
        $stmt = $db->query("SELECT * FROM ticket_details ORDER BY ticket_id DESC LIMIT 10");
        $stats['recent_bookings'] = $stmt->fetchAll();
        
        sendResponse(true, $stats);
    } catch(PDOException $e) {
        sendResponse(false, null, $e->getMessage());
    }
}

// ============================================
// SEARCH TRAINS
// ============================================
if ($action === 'search_trains') {
    $source = isset($_GET['source']) ? $_GET['source'] : '';
    $destination = isset($_GET['destination']) ? $_GET['destination'] : '';
    $date = isset($_GET['date']) ? $_GET['date'] : '';
    
    try {
        $stmt = $db->query("SELECT * FROM train_availability WHERE source LIKE '%$source%' AND destination LIKE '%$destination%' AND journey_date = '$date'");
        $trains = $stmt->fetchAll();
        sendResponse(true, $trains);
    } catch(PDOException $e) {
        sendResponse(false, null, $e->getMessage());
    }
}

sendResponse(false, null, 'Invalid request');
?>
