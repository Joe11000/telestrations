import React from 'react';
import {shallow} from 'enzyme';
import OutOfGameCardUploadTab from 'packs/postgame/TabBody/OutOfGameCardUploadTab';
import { mock_games_show_request_for_last_postgame } from '../fixtures/mocks/responses/mock_games_show_request_for_last_postgame';

// import enzymeSerializer from 'enzyme-to-json/serializer';
// expect.addSnapshotSerializer(enzymeSerializer)

describe('OutOfGameCardUploadTab Component', () => {

  describe('user does NOT have out_of_game_card_uploads', () => {
    it('displays a message if user has no out of game card uploads', () => {
      const mockRetrieveOutOfGameCards = jest.fn();
      const params = {
        current_user_info: mock_games_show_request_for_last_postgame.current_user_info,
        ...mock_games_show_request_for_last_postgame.OutOfGameCardUploadTab,
        retrieveOutOfGameCards: mockRetrieveOutOfGameCards
      }
      params.out_of_game_cards  = [];

      const post_game_tab_component = shallow(<OutOfGameCardUploadTab {...params } />);
      debugger
      expect(post_game_tab_component.find('h2').text()).toEqual("You don't have any images uploaded out of game")
    });

    fit('does not have a SlideshowList on screen', () => {
      const mockRetrieveOutOfGameCards = jest.fn();
      const params = {
        current_user_info: mock_games_show_request_for_last_postgame.current_user_info,
        ...mock_games_show_request_for_last_postgame.OutOfGameCardUploadTab,
        retrieveOutOfGameCards: mockRetrieveOutOfGameCards
      }
      params.out_of_game_cards = [];

      const post_game_tab_component = shallow(<OutOfGameCardUploadTab {...params } />);
      debugger
      expect(post_game_tab_component.find('SlideshowList').exists()).toEqual(false);
    });
    it('calls retrieveOutOfGameCards in componentDidMount', () => {
      const mockRetrieveOutOfGameCards = jest.fn();
      const params = {
        current_user_info: mock_games_show_request_for_last_postgame.current_user_info,
        ...mock_games_show_request_for_last_postgame.OutOfGameCardUploadTab,
        retrieveOutOfGameCards: mockRetrieveOutOfGameCards
      }
      params.out_of_game_cards = null;

      shallow(<OutOfGameCardUploadTab {...params } />);
      expect(mockRetrieveOutOfGameCards.mock.calls.length).toEqual(1);
    })
  })

  describe('user does have out_of_game_card_uploads', () => {
    it('renders card title', () => {
      const mockRetrieveOutOfGameCards = jest.fn();
      const params = {
        current_user_info: mock_games_show_request_for_last_postgame.current_user_info,
        ...mock_games_show_request_for_last_postgame.OutOfGameCardUploadTab,
        retrieveOutOfGameCards: mockRetrieveOutOfGameCards
      };
      const post_game_tab_component = shallow(<OutOfGameCardUploadTab {...params } />);

      expect(post_game_tab_component.find('CardTitle').children().text()).toEqual('Your Drawings not associated to a game');
    })

    it('creates a single list of slideshows that receive the correct props ', () => {
      const mockRetrieveOutOfGameCards = jest.fn();

      const post_game_tab_props = {
                                    ...mock_games_show_request_for_last_postgame.OutOfGameCardUploadTab,
                                    retrieveOutOfGameCards: mockRetrieveOutOfGameCards,
                                    current_user_info: { ...mock_games_show_request_for_last_postgame.current_user_info }
                                  };

      const post_game_tab_component = shallow(<OutOfGameCardUploadTab {...post_game_tab_props } />);

      const expected_slideshow_list_props = {
                                              current_user_info: { ...mock_games_show_request_for_last_postgame.current_user_info },
                                              arr_of_decks_of_cards: mock_games_show_request_for_last_postgame.OutOfGameCardUploadTab.out_of_game_cards
                                            };
      const SlideshowList = post_game_tab_component.find('SlideshowList');
      expect(SlideshowList.length).toEqual(1);

      expect(SlideshowList.props()).toEqual(expected_slideshow_list_props);
    })

    it('does not call retrieveOutOfGameCards in componentDidMount if they already exist', () => {
      const mockRetrieveOutOfGameCards = jest.fn();
      const params = {
        current_user_info: mock_games_show_request_for_last_postgame.current_user_info,
        ...mock_games_show_request_for_last_postgame.OutOfGameCardUploadTab,
        retrieveOutOfGameCards: mockRetrieveOutOfGameCards
      }
      shallow(<OutOfGameCardUploadTab {...params } />);
      debugger
      expect(mockRetrieveOutOfGameCards.mock.calls.length).toEqual(0);
    })
  })
});
