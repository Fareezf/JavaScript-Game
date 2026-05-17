
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kings and Pigs</title>
    <style>
        body {
            background-color: rgb(255, 255, 255);
            margin: 0;
        }
        canvas {
            display: block;
            margin: auto;
            margin-top: 5%;
            background-color: black;
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <canvas id="gameCanvas"></canvas>
    <script>
        const canvas = document.getElementById('gameCanvas');
        const ctx = canvas.getContext('2d');

        canvas.width = 1280; // Increased width
        canvas.height = 720; // Increased height

        const groundHeight = 50; // Height of the ground
        const MOVE_SPEED = 7; // Player speed
        const JUMP_FORCE = -20; // Jump height
        const GRAVITY = 1;

        // Player Class
        class Player {
            constructor(x, y, width, height) {
                this.position = { x: x, y: y };
                this.width = width; // Smaller width
                this.height = height; // Smaller height
                this.velocity = { x: 0, y: 0 };
                this.isGrounded = true;
            }

            draw() {
                ctx.fillStyle = 'red';
                ctx.fillRect(this.position.x, this.position.y, this.width, this.height);
            }

            update() {
                // Apply gravity
                this.velocity.y += GRAVITY;

                // Update position
                this.position.x += this.velocity.x;
                this.position.y += this.velocity.y;

                // Check for ground collision
                if (this.position.y + this.height >= canvas.height - groundHeight) {
                    this.position.y = canvas.height - groundHeight - this.height; // Reset to ground level
                    this.velocity.y = 0; // Reset vertical velocity
                    this.isGrounded = true; // Player is on the ground
                }
            }
        }

        // Spawn player on a platform
        const player = new Player(200, 500, 30, 30); // Smaller player size

        const keys = {
            ArrowLeft: false,
            ArrowRight: false,
            a: false,
            d: false,
            w: false,
            ArrowUp: false,
            Space: false,
        };

        window.addEventListener('keydown', (event) => {
            switch (event.key) {
                case 'w':
                case 'ArrowUp':
                case 'Space':
                    if (player.isGrounded) {
                        player.velocity.y = JUMP_FORCE; // Apply jump force
                        player.isGrounded = false; // Player is no longer grounded
                    }
                    break;
                case 'a':
                case 'ArrowLeft':
                    keys.ArrowLeft = true;
                    keys.a = true;
                    break;
                case 'd':
                case 'ArrowRight':
                    keys.ArrowRight = true;
                    keys.d = true;
                    break;
            }
        });

        window.addEventListener('keyup', (event) => {
            switch (event.key) {
                case 'a':
                case 'ArrowLeft':
                    keys.ArrowLeft = false;
                    keys.a = false;
                    break;
                case 'd':
                case 'ArrowRight':
                    keys.ArrowRight = false;
                    keys.d = false;
                    break;
            }
        });

        // Platforms
        const platforms = [
            { x: 200, y: 500, width: 150, height: 10 },
            { x: 500, y: 400, width: 150, height: 10 },
            { x: 800, y: 300, width: 150, height: 10 },
            { x: 300, y: 600, width: 150, height: 10 },
            { x: 600, y: 200, width: 150, height: 10 },
            { x: 1000, y: 150, width: 150, height: 10 }
        ];

        // Stars
        const stars = [
            { x: 220, y: 470, width: 20, height: 20 },
            { x: 520, y: 370, width: 20, height: 20 },
            { x: 820, y: 270, width: 20, height: 20 }
        ];

        // Lava
        const lava = { x: 0, y: canvas.height - groundHeight, width: canvas.width, height: 20 };

        function update() {
            // Horizontal movement
            if (keys.ArrowLeft || keys.a) {
                player.velocity.x = -MOVE_SPEED; // Move left
            } else if (keys.ArrowRight || keys.d) {
                player.velocity.x = MOVE_SPEED; // Move right
            } else {
                player.velocity.x = 0; // Stop moving when no key is pressed
            }

            player.update();

            // Check for collisions with platforms
            platforms.forEach(platform => {
                if (player.position.x < platform.x + platform.width &&
                    player.position.x + player.width > platform.x &&
                    player.position.y + player.height >= platform.y &&
                    player.position.y + player.height <= platform.y + platform.height) {
                    // Collision detected
                    player.position.y = platform.y - player.height; // Reset player position
                    player.velocity.y = 0; // Stop falling
                    player.isGrounded = true; // Player is on the ground
                }
            });

            // Check for collisions with lava
            if (player.position.y + player.height >= lava.y) {
                alert("You fell into the lava! Game Over.");
                document.location.reload(); // Reload the game
            }

            // Check for collecting stars
            stars.forEach((star, index) => {
                if (player.position.x < star.x + star.width &&
                    player.position.x + player.width > star.x &&
                    player.position.y < star.y + star.height &&
                    player.position.y + player.height > star.y) {
                    // Collision detected
                    stars.splice(index, 1); // Remove star from array
                }
            });
        }

        // Background Animation
        let backgroundOffset = 0;

        function drawBackground() {
            // Create a gradient background
            const gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
            gradient.addColorStop(0, 'lightblue');
            gradient.addColorStop(1, 'lightgreen');
            ctx.fillStyle = gradient;
            ctx.fillRect(0, 0, canvas.width, canvas.height);

            // Draw animated clouds
            ctx.fillStyle = 'white';
            ctx.beginPath();
            ctx.arc(100 + backgroundOffset, 100, 30, 0, Math.PI * 2); // Cloud 1
            ctx.fill();
            ctx.beginPath();
            ctx.arc(300 + backgroundOffset, 150, 40, 0, Math.PI * 2); // Cloud 2
            ctx.fill();
            ctx.beginPath();
            ctx.arc(600 + backgroundOffset, 80, 35,            0, Math.PI * 2); // Cloud 3
            ctx.fill();

            // Update the background offset for animation
            backgroundOffset += 0.5; // Adjust speed of cloud movement
            if (backgroundOffset > canvas.width) {
                backgroundOffset = 0; // Reset offset for seamless animation
            }
        }

        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            drawBackground(); // Draw the animated background
            update();
            player.draw();

            // Draw the ground
            ctx.fillStyle = 'green';
            ctx.fillRect(0, canvas.height - groundHeight, canvas.width, groundHeight);

            // Draw platforms
            ctx.fillStyle = 'blue';
            platforms.forEach(platform => {
                ctx.fillRect(platform.x, platform.y, platform.width, platform.height);
            });

            // Draw stars
            ctx.fillStyle = 'yellow';
            stars.forEach(star => {
                ctx.fillRect(star.x, star.y, star.width, star.height);
            });

            // Draw lava
            ctx.fillStyle = 'orange';
            ctx.fillRect(lava.x, lava.y, lava.width, lava.height);

            requestAnimationFrame(animate);
        }

        animate();
    </script>
</body>
</html>