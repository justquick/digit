choose = (choices) ->
  choices[Math.floor Math.random() * choices.length]

class Mario
    constructor: ->
        @game = new Phaser.Game 800, 600, Phaser.AUTO, '',  {preload: @preload, create: @create, update: @update}
        @score = 0
        @scoreText

    collectStar: (player, star) =>
        star.kill()
        @score += 1
        @scoreText.text = 'Score: ' + @score
        if @score is 13
            @scoreText.text = 'YOU WIN!'
            @game.paused = true

    gameOver: (player, baddie) =>
        @scoreText.text = 'GAME OVER!'
        @game.paused = true

    createBaddie: =>
        baddie = @game.add.sprite Math.random() * 800, 0, 'baddie'
        @game.physics.arcade.enable baddie
        baddie.body.bounce.y = 0.0
        baddie.body.gravity.y = 10000
        baddie.body.collideWorldBounds = true
        baddie.animations.add 'left', [0, 1], 10, true
        baddie.animations.add 'right', [2, 3], 10, true
        baddie.direction = choose ['left', 'right']
        @baddies.push baddie

    preload: =>
        @game.load.image 'sky', 'assets/images/sky.png'
        @game.load.image 'grass', 'assets/images/grass.png'
        @game.load.image 'star', 'assets/images/star.png'
        @game.load.image 'rock', 'assets/images/rock.png'
        @game.load.spritesheet 'dude', 'assets/images/dude.png', 32, 48
        @game.load.spritesheet 'baddie', 'assets/images/baddie.png', 32, 32
        @cursors = @game.input.keyboard.createCursorKeys()

    create: =>
        @game.add.sprite 0, 0, 'sky'
        @scoreText = @game.add.text 16, 16, 'Score: 0', { fontSize: '32px', fill: '#000' }
        @platforms = window.platforms = @game.add.group()
        @platforms.enableBody = true
        @tiles = window.tiles = {}
        @baddies = window.baddies = []

        for w in [0..16]
            for h in [1..10]
                tile = @platforms.create w * 50, h * 50, 'grass'
                tile.body.immovable = true
                tile.body.checkCollision.left = false
                tile.body.checkCollision.down = false
                tile.body.checkCollision.right = false
                @tiles[w] = {} if not @tiles[w]?
                @tiles[w][h] = tile
            rock = @platforms.create w * 50, 550, 'rock'
            rock.body.immovable = true

        @player = window.player = @game.add.sprite 0, 0, 'dude'
        @game.physics.arcade.enable @player
        @player.body.bounce.y = 0.2
        @player.body.gravity.y = 600
        @player.body.collideWorldBounds = true
        @player.animations.add 'left', [0..3], 10, true
        @player.animations.add 'right', [5..8], 10, true

        @stars = @game.add.group()
        @stars.enableBody = true
        for i in [0..12]
            star = @stars.create Math.random() * 800, Math.random() * 550, 'star'
            star.body.gravity.y = 600
            star.body.bounce.y = 0.7 + Math.random() * 0.2

         @game.time.events.repeat Phaser.Timer.SECOND * 3, 10, @createBaddie

    update: =>
        @game.physics.arcade.collide @player, @platforms
        @game.physics.arcade.collide @baddie, @platforms
        @game.physics.arcade.collide @platforms, @stars
        @game.physics.arcade.overlap @player, @stars, @collectStar
        @player.body.velocity.x = 0

        for baddie in @baddies
            @game.physics.arcade.collide baddie, @platforms
            if baddie.body.position.x is 0
                baddie.direction = 'right'
            else if baddie.body.position.x is 768
                baddie.direction = 'left'
            if baddie.direction is 'right'
                baddie.body.velocity.x = 300
                baddie.animations.play 'right'
            else
                baddie.body.velocity.x = -300
                baddie.animations.play 'left'

        if @cursors.left.isDown
            @player.body.velocity.x = -150
            @player.animations.play 'left'
        else if @cursors.right.isDown
            @player.body.velocity.x = 150
            @player.animations.play 'right'
        else
            @player.animations.stop();
            @player.frame = 4
        if @cursors.up.isDown and @player.body.touching.down
            @player.body.velocity.y = -350
        if @cursors.down.isDown and @player.body.touching.down
            x = @player.position.x / 50
            y = @player.position.y / 50 + 1
            for algo in [Math.round, Math.floor, Math.ceil]
                tile = @tiles[algo x][algo y]
                if tile? and tile.visible
                    tile.destroy()
                    tile.body.checkCollision.up = false
                    break
            @player.body.velocity.y = 50
        @game.physics.arcade.collide @player, @platforms
        for baddie in @baddies
            @game.physics.arcade.collide @player, baddie, @gameOver

window.mario = new Mario