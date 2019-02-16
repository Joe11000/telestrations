import React from 'react';
import { mount, shallow } from 'enzyme';
import  GameSelector  from 'packs/postgame/GameSelector';
import { mock_games_show_request } from '../mock_games_show_request';
// import enzymeSerializer from 'enzyme-to-json/serializer';
// expect.addSnapshotSerializer(enzymeSerializer);

describe('GameSelector Component', ()=>{
  describe('sets correct values', ()=>{
    it('onload, default selects last game played', ()=>{
      const mockRetrieveCardsForPostgame = jest.fn();
      const game_selector_props = {
        all_postgames_of__current_user: mock_games_show_request.OutOfGameCardUploadTab.out_of_game_cards,
        current_postgame_id: mock_games_show_request.PostGameTab.current_postgame_id,
        retrieveCardsForPostgame: mockRetrieveCardsForPostgame
      }
      const GameSelectorComponent = shallow(<GameSelector {...game_selector_props } />);


      const selector_button = GameSelectorComponent.find("select");
      expect(selector_button.props().value).toEqual(7);
    });
    
    it('options created correct information', () => {
      const mockRetrieveCardsForPostgame = jest.fn();
      const game_selector_props = {
        all_postgames_of__current_user: mock_games_show_request.OutOfGameCardUploadTab.out_of_game_cards,
        current_postgame_id: mock_games_show_request.PostGameTab.current_postgame_id,
        retrieveCardsForPostgame: mockRetrieveCardsForPostgame
      }
      const GameSelectorComponent = shallow(<GameSelector {...game_selector_props } />);


      GameSelectorComponent.find('option').forEach(function(option, index)  {
        // option key is correct
          const expected_game = game_selector_props.all_postgames_of__current_user[index];
          expect(option.key()).toEqual(`game_selector_postgame_id_${expected_game.id}`);
        
        // option value is correct
          expect(option.props().value).toEqual(expected_game.id);

        // option text is correct
          expect(option.text()).toEqual(`Game ${index + 1} - ${expected_game.created_at_strftime}`)
      }.bind(this))
    });

    it('selector onChange calls props.retrieveCardsForPostgame(game_id)', ()=>{
      const mockRetrieveCardsForPostgame = jest.fn();
      const game_selector_props = {
        all_postgames_of__current_user: mock_games_show_request.OutOfGameCardUploadTab.out_of_game_cards,
        current_postgame_id: mock_games_show_request.PostGameTab.current_postgame_id,
        retrieveCardsForPostgame: mockRetrieveCardsForPostgame
      }
      const GameSelectorComponent = mount(<GameSelector {...game_selector_props } />);
      const game_1 = game_selector_props.all_postgames_of__current_user[0];
      
      const change_to_value = game_1.id;
      let params = {'target': {'value': change_to_value }, "preventDefault": ()=>{} }
      
      GameSelectorComponent.find('select').simulate('change', params )

      expect(mockRetrieveCardsForPostgame.mock.calls.length).toBe(1);
      expect(mockRetrieveCardsForPostgame).toBeCalledWith(change_to_value);
    });
  });
});
