# RSpec.shared_examples 'a valid pregame' do |pregame|
#   it 'is valid' do
#     users = pregame.users
#

#     expect(pregame.pregame?).to eq true
#     expect(pregame.midgame?).to eq false
#     expect(pregame.postgame?).to eq false
#     expect(pregame.passing_order).to eq ''
#     expect(pregame.join_code).to match /[A-Z]{4}/
#     expect(pregame.description_first).to eq true
#     expect(pregame.valid?).to eq true
#     expect(pregame.cards).to be_blank
#     expect(users.length).to eq 3

#     gus = pregame.games_users
#     expect(gus.length).to eq 3
#     gus.each do |gu|
#       expect(gu.users_game_name).to eq nil
#       expect(gu.set_complete).to eq false
#       expect(gu.starting_card).to eq nil
#     end
#   end
# end

# RSpec.shared_examples 'a valid midgame_with_no_moves' do |*args|
#   it 'is valid' do
#     midgame_with_no_moves = described_class.create(*args)
#     users = midgame_with_no_moves.users
#

#     expect(midgame_with_no_moves.pregame?).to eq false
#     expect(midgame_with_no_moves.midgame?).to eq true
#     expect( JSON.parse(midgame_with_no_moves.passing_order) ).to match_array(users.pluck(:id))
#     expect(midgame_with_no_moves.postgame?).to eq false
#     expect(midgame_with_no_moves.valid?).to eq true
#     expect(midgame_with_no_moves.join_code).to be_nil
#     expect(midgame_with_no_moves.description_first?).to eq true
#     expect(midgame_with_no_moves.cards.length).to eq 3

#     gus = midgame_with_no_moves.games_users
#     expect(gus.length).to eq 3
#     gus.map(&:starting_card).each do |starting_card|
#       expect(starting_card.description_text).to eq nil
#       expect(starting_card.description?).to eq true
#       expect(starting_card.child_card).to eq nil
#     end

#     expect(users.length).to eq 3
#     expect(users.map(&:current_games_user_name)).to all(be_a String)
#   end
# end

# RSpec.shared_examples 'a valid midgame' do |midgame|
#   it 'is valid' do
#     users = midgame.users
#     gus = midgame.games_users
#

#     expect( JSON.parse(midgame.passing_order) ).to match_array users.pluck(:id)
#     expect(midgame.valid?).to eq true
#     expect(midgame.join_code).to be_nil
#     expect(midgame.description_first?).to eq true
#     expect(midgame.pregame?).to eq false
#     expect(midgame.midgame?).to eq true
#     expect(midgame.cards.length).to eq 6
#     expect(gus.length).to eq 3

#     # player 1 only has a placeholder
#     gu1 = gus[0]
#     gu1_starting_card = gu1.starting_card
#     expect(gu1_starting_card.description_text).to eq nil
#     expect(gu1_starting_card.description?).to eq true
#     expect(gu1_starting_card.child_card).to eq nil

#     # player 2 submitted one description and has one drawing placeholder
#     gu2 = gus[1]
#     gu2_starting_card = gu2.starting_card
#     expect(gu2_starting_card.description_text).to be_a String
#     expect(gu2_starting_card.description?).to eq true
#     expect(gu2_starting_card.child_card).to be_a Card

#     expect(gu2_starting_card.child_card.description_text).to eq nil
#     expect(gu2_starting_card.child_card.drawing?).to eq true
#     expect(gu2_starting_card.child_card.drawing.attached?).to eq false
#     expect(gu2_starting_card.child_card.child_card).to eq nil

#     # player 3 has 3 cards, 1 submitted description, 1 submitted drawing, 1 description placeholder
#     gu3 = gus[2]
#     gu3_starting_card = gu3.starting_card
#     expect(gu3_starting_card.description_text).to be_a String
#     expect(gu3_starting_card.description?).to eq true
#     expect(gu3_starting_card.child_card).to be_a Card

#     expect(gu3_starting_card.child_card.description_text).to eq nil
#     expect(gu3_starting_card.child_card.drawing?).to eq true
#     expect(gu3_starting_card.child_card.drawing.attached?).to eq true
#     expect(gu3_starting_card.child_card.child_card).to be_a Card

#     expect(gu3_starting_card.child_card.child_card.description_text).to eq nil
#     expect(gu3_starting_card.child_card.child_card.description?).to eq true
#     expect(gu3_starting_card.child_card.child_card.child_card).to eq nil

#     expect(users.length).to eq 3
#     expect(users.map(&:current_games_user_name)).to all(be_a String)
#   end
# end

# RSpec.shared_examples 'a valid postgame' do |postgame|
#   it 'is valid' do
#     gus = postgame.games_users
#

#     expect(postgame.valid?).to eq true
#     expect(postgame.join_code).to be_nil
#     expect(postgame.description_first?).to eq true
#     expect(postgame.postgame?).to eq true
#     expect(postgame.cards.length).to eq 9
#     expect(gus.length).to eq 3

#     gus.each do |gu|
#       expect(gu.users_game_name).to be_a String
#       expect(gu.set_complete).to eq true

#       starting_card = gu.starting_card
#       expect(starting_card.description_text).to be_a String
#       expect(starting_card.description?).to eq true
#       expect(starting_card.child_card).to be_a Card

#       expect(starting_card.child_card.description_text).to eq nil
#       expect(starting_card.child_card.drawing?).to eq true
#       expect(starting_card.child_card.drawing.attached?).to eq true
#       expect(starting_card.child_card.child_card).to be_a Card

#       expect(starting_card.child_card.child_card.description_text).to be_a String
#       expect(starting_card.child_card.child_card.description?).to eq true
#       expect(starting_card.child_card.child_card.child_card).to eq nil

#     end
#     users = postgame.users
#     expect( JSON.parse(postgame.passing_order) ).to match_array users.pluck(:id)
#     expect(postgame.users.length).to eq 3
#   end
# end
