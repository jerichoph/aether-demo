extends Node


var playerBody: CharacterBody2D

var playerAlive: bool
var playerDamageZone: Area2D
var playerDamageAmount: int

var batDamageZone: Area2D
var batDamageAmount: int

var golluxSmashZone: Area2D
var golluxDamageAmount: int


var high_score = 0
var current_score: int
var previous_score: int

var key_fragments = 0:
	set(value):
			key_fragments = value
			if UI:
				UI.update_key_count(key_fragments)
var keys_needed = 3
var UI
