import React from 'react';
import { shallow } from 'enzyme';
// import TestRenderer from 'react-test-renderer';
import SlideshowList from 'packs/postgame/SlideshowList';
import {mock_games_index_request} from '../mock_games_index_request';


describe('SlideshowList component', () => {
  it("3 Slideshow components created with correct params", () => {
    const props = { arr_of_decks_of_cards: mock_games_index_request.arr_of_postgame_card_set, 
      current_user_info: mock_games_index_request.current_user_info, 
      needsAKeyBasedOnCardIds: true
     };
    const slideshow_component = shallow(<SlideshowList {...props} />);
    expect(slideshow_component.find('Slideshow').length).toEqual(3);

    const current_user_info = {};
    current_user_info.current_user_info = props.current_user_info;

    const slideshows = slideshow_component.find('Slideshow')
    // current_user_info = current_user_info.current_user_info;
    expect(slideshows.at(0).props()).toEqual({ ...current_user_info, deck: props.arr_of_decks_of_cards[0] })
    expect(slideshows.at(1).props()).toEqual({ ...current_user_info, deck: props.arr_of_decks_of_cards[1] })
    expect(slideshows.at(2).props()).toEqual({ ...current_user_info, deck: props.arr_of_decks_of_cards[2] })
  });
});
